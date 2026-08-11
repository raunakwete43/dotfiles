#!/usr/bin/env bash

set -u

# ============================================================
# fanctl - Simple ASUS EC fan curve controller
# ============================================================

RPMCTL="./rpmctl.sh"
POLL_INTERVAL=1

# Active profile when started without an explicit profile.
DEFAULT_PROFILE="balanced"

# ============================================================
# Profiles
#
# Format:
#
#   "temperature:fan_percentage"
#
# The temperature is the point at which that fan level becomes
# active while temperature is RISING.
#
# Falling temperature uses 5°C hysteresis.
# ============================================================

BALANCED_CURVE=(
    "55:20"
    "60:30"
    "65:45"
    "70:55"
    "75:60"
    "80:70"
    "85:80"
    "90:90"
)

# ------------------------------------------------------------
# Add your own curves later.
# ------------------------------------------------------------

SILENT_CURVE=()

GAMING_CURVE=()


# ============================================================
# Runtime state
# ============================================================

HWMON_PATH=""
CURRENT_PROFILE=""
CURRENT_LEVEL=-1
CURRENT_FAN=-1
RUNNING=1


# ============================================================
# Temperature sensor discovery
# ============================================================

find_k10temp()
{
    local hwmon

    for hwmon in /sys/class/hwmon/hwmon*/name; do

        [[ -e "$hwmon" ]] || continue

        if grep -q '^k10temp$' "$hwmon"; then
            HWMON_PATH="$(dirname "$hwmon")/temp1_input"
            break
        fi

    done

    if [[ -z "$HWMON_PATH" ]]; then
        echo "ERROR: k10temp sensor not found." >&2
        return 1
    fi

    if [[ ! -r "$HWMON_PATH" ]]; then
        echo "ERROR: Cannot read temperature sensor:" >&2
        echo "  $HWMON_PATH" >&2
        return 1
    fi

    return 0
}


# ============================================================
# Read CPU temperature
#
# k10temp reports millidegrees Celsius:
#
#   67250 -> 67°C
#
# Integer temperature is intentional because our curve operates
# in 5°C steps.
# ============================================================

read_temperature()
{
    local raw

    if ! raw=$(<"$HWMON_PATH"); then
        return 1
    fi

    [[ "$raw" =~ ^[0-9]+$ ]] || return 1

    echo $(( raw / 1000 ))
}


# ============================================================
# Profile handling
# ============================================================

profile_exists()
{
    case "$1" in

        balanced)
            return 0
            ;;

        silent)
            [[ ${#SILENT_CURVE[@]} -gt 0 ]]
            return
            ;;

        gaming|perf|performance)
            [[ ${#GAMING_CURVE[@]} -gt 0 ]]
            return
            ;;

        *)
            return 1
            ;;
    esac
}


load_profile()
{
    local profile="$1"

    case "$profile" in

        balanced)
            CURVE=( "${BALANCED_CURVE[@]}" )
            CURRENT_PROFILE="balanced"
            ;;

        silent)

            if [[ ${#SILENT_CURVE[@]} -eq 0 ]]; then
                echo "ERROR: Silent profile is not configured."
                return 1
            fi

            CURVE=( "${SILENT_CURVE[@]}" )
            CURRENT_PROFILE="silent"
            ;;

        gaming|perf|performance)

            if [[ ${#GAMING_CURVE[@]} -eq 0 ]]; then
                echo "ERROR: Gaming profile is not configured."
                return 1
            fi

            CURVE=( "${GAMING_CURVE[@]}" )
            CURRENT_PROFILE="gaming"
            ;;

        *)

            echo "ERROR: Unknown profile: $profile"
            return 1
            ;;
    esac
}


# ============================================================
# EC fan control
# ============================================================

set_fan()
{
    local percent="$1"

    # Don't touch the EC if nothing actually changed.
    if (( percent == CURRENT_FAN )); then
        return 0
    fi

    echo "Fan: ${CURRENT_FAN}% -> ${percent}%"

    if ! "$RPMCTL" "$percent"; then

        echo "ERROR: Failed to set fan to ${percent}%." >&2

        return 1
    fi

    CURRENT_FAN="$percent"

    return 0
}


restore_auto()
{
    echo
    echo "Restoring ASUS EC automatic fan control..."

    "$RPMCTL" auto

    CURRENT_FAN=-1
}


# ============================================================
# Determine initial fan level
# ============================================================

find_initial_level()
{
    local temp="$1"

    local level=-1
    local i
    local threshold

    for (( i=0; i<${#CURVE[@]}; i++ )); do

        threshold="${CURVE[$i]%%:*}"

        if (( temp >= threshold )); then
            level="$i"
        else
            break
        fi

    done

    echo "$level"
}


# ============================================================
# Main curve logic
#
# Example:
#
#       60°C -> 30%
#       65°C -> 40%
#
# Rising:
#
#       64 -> 30%
#       65 -> 40%
#
# Falling:
#
#       65 -> 40%
#       64 -> still 40%
#       ...
#       60 -> 30%
#
# Therefore each level has approximately 5°C down hysteresis.
# ============================================================

update_curve()
{
    local temp="$1"

    local curve_count=${#CURVE[@]}
    local last_level=$(( curve_count - 1 ))

    local threshold
    local fan

    # --------------------------------------------------------
    # First update
    # --------------------------------------------------------

    if (( CURRENT_LEVEL == -1 )); then

        CURRENT_LEVEL=$(find_initial_level "$temp")

        # Below the first threshold.
        if (( CURRENT_LEVEL < 0 )); then

            set_fan 0
            return
        fi

        fan="${CURVE[$CURRENT_LEVEL]#*:}"

        set_fan "$fan"

        return
    fi


    # --------------------------------------------------------
    # Temperature rising
    #
    # Allow jumping several levels if temperature suddenly
    # increases.
    # --------------------------------------------------------

    while (( CURRENT_LEVEL < last_level )); do

        local next_level=$(( CURRENT_LEVEL + 1 ))

        threshold="${CURVE[$next_level]%%:*}"

        if (( temp >= threshold )); then
            CURRENT_LEVEL="$next_level"
        else
            break
        fi

    done


    # --------------------------------------------------------
    # Temperature falling
    #
    # Current level itself defines the point where we return
    # to the previous level.
    #
    # Example:
    #
    # Current level:
    #
    #       65 -> 40%
    #
    # Return to 30% when temperature reaches 60°C.
    # --------------------------------------------------------

    while (( CURRENT_LEVEL >= 0 )); do

        threshold="${CURVE[$CURRENT_LEVEL]%%:*}"

        local down_threshold=$(( threshold - 5 ))

        if (( temp <= down_threshold )); then
            CURRENT_LEVEL=$(( CURRENT_LEVEL - 1 ))
        else
            break
        fi

    done


    # --------------------------------------------------------
    # Below first fan threshold
    # --------------------------------------------------------

    if (( CURRENT_LEVEL < 0 )); then

        set_fan 0
        return
    fi


    # --------------------------------------------------------
    # Apply fan level
    # --------------------------------------------------------

    fan="${CURVE[$CURRENT_LEVEL]#*:}"

    set_fan "$fan"
}


# ============================================================
# Controller
# ============================================================

run_controller()
{
    local profile="$1"

    load_profile "$profile" || return 1

    find_k10temp || return 1


    if [[ ! -x "$RPMCTL" ]]; then

        echo "ERROR: rpmctl.sh not found or isn't executable:"
        echo "  $RPMCTL"
        echo
        echo "Expected fanctl and rpmctl.sh to be in the same directory."

        return 1
    fi


    echo "ASUS Fan Curve Controller"
    echo
    echo "Profile: $CURRENT_PROFILE"
    echo "Sensor:  $HWMON_PATH"
    echo "Poll:    ${POLL_INTERVAL}s"
    echo
    echo "Curve:"

    local point

    for point in "${CURVE[@]}"; do

        local temp="${point%%:*}"
        local fan="${point#*:}"

        printf "  %2d°C -> %2d%%\n" "$temp" "$fan"

    done

    echo
    echo "Below ${CURVE[0]%%:*}°C -> 0%"
    echo
    echo "Press Ctrl+C to stop."
    echo


    # Restore firmware control whenever the controller exits
    # normally through SIGINT/SIGTERM.
    trap 'RUNNING=0' INT TERM


    while (( RUNNING )); do

        local temp

        if ! temp=$(read_temperature); then

            echo "ERROR: Failed to read CPU temperature." >&2
            break

        fi

        update_curve "$temp"

        printf '\rTemp: %3d°C | Fan: %3d%% | Profile: %-10s' \
            "$temp" \
            "$CURRENT_FAN" \
            "$CURRENT_PROFILE"

        sleep "$POLL_INTERVAL"

    done


    restore_auto

    echo
}


# ============================================================
# Usage
# ============================================================

usage()
{
    cat <<EOF
ASUS Fan Curve Controller

Usage:

  $0 run [profile]
  $0 auto
  $0 profiles

Profiles:

  silent       Not configured
  balanced     Configured
  gaming       Not configured

Examples:

  $0 run
  $0 run balanced
  $0 run silent
  $0 run gaming

  $0 auto

EOF
}


# ============================================================
# CLI
# ============================================================

COMMAND="${1:-}"

case "$COMMAND" in

    run)

        PROFILE="${2:-$DEFAULT_PROFILE}"

        run_controller "$PROFILE"
        ;;


    auto)

        "$RPMCTL" auto
        ;;


    profiles)

        echo "Available profiles:"
        echo
        echo "  Silent     [not configured]"
        echo "  Balanced   [configured]"
        echo "  Gaming     [not configured]"
        ;;


    -h|--help|help|"")
        usage
        ;;


    *)

        echo "ERROR: Unknown command: $COMMAND"
        echo
        usage
        exit 1
        ;;

esac
