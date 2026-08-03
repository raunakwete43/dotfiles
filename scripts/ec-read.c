#define _POSIX_C_SOURCE 200809L

#include <errno.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/io.h>
#include <time.h>

/*
 * ASUS EC ports discovered from the driver.
 *
 * 0x25C = DATA
 * 0x25D = STATUS / COMMAND
 */
#define EC_DATA 0x25C
#define EC_CMD 0x25D
#define EC_STATUS 0x25D

#define EC_OBF 0x01
#define EC_IBF 0x02

#define EC_TIMEOUT 1000
#define EC_DELAY_NS 100000L /* 100 us */

/*
 * Safety limit.
 *
 * Even if the user requests 100%, we only send 95%.
 */
#define MAX_FAN_PERCENT 95

/* ASUS HealthyTable EC protocol */
#define ASUS_EC_COMMAND 0xDD

#define HEALTHY_TABLE_PREFIX 0x82
#define HEALTHY_TABLE_FAN_TEST_MODE 0x31
#define HEALTHY_TABLE_FAN_INDEX 0x32
#define HEALTHY_TABLE_FAN_PWM 0x35

/* ============================================================
 * Timing
 * ============================================================ */

static void delay_100us(void) {
  struct timespec ts = {.tv_sec = 0, .tv_nsec = EC_DELAY_NS};

  nanosleep(&ts, NULL);
}

/* ============================================================
 * Low-level EC functions
 * ============================================================ */

/*
 * Equivalent to fcn.1400016a4:
 *
 * Wait until STATUS bit 1 (IBF) clears.
 */
static int wait_ibf_clear(void) {
  if (!(inb(EC_STATUS) & EC_IBF))
    return 0;

  for (unsigned int i = 0; i < EC_TIMEOUT; i++) {
    delay_100us();

    if (!(inb(EC_STATUS) & EC_IBF))
      return 0;
  }

  return -ETIMEDOUT;
}

/*
 * Equivalent to fcn.140001734:
 *
 * Drain pending EC output while OBF is set.
 */
static int drain_output(void) {
  if (!(inb(EC_STATUS) & EC_OBF))
    return 0;

  for (unsigned int i = 0; i < EC_TIMEOUT; i++) {
    (void)inb(EC_DATA);

    delay_100us();

    if (!(inb(EC_STATUS) & EC_OBF))
      return 0;
  }

  return -ETIMEDOUT;
}

/*
 * Equivalent to fcn.140001bcc:
 *
 * Wait for IBF clear and write to command port.
 */
static int write_command(uint8_t value) {
  int ret = wait_ibf_clear();

  if (ret)
    return ret;

  outb(value, EC_CMD);

  return 0;
}

/*
 * Equivalent to fcn.140001c4c:
 *
 * Wait for IBF clear and write to data port.
 */
static int write_data(uint8_t value) {
  int ret = wait_ibf_clear();

  if (ret)
    return ret;

  outb(value, EC_DATA);

  return 0;
}

/*
 * Send an ASUS EC transaction.
 *
 * Sequence:
 *
 *   CMD  0xFF
 *   CMD  command
 *   DATA payload[0]
 *   DATA payload[1]
 *   ...
 *
 * For HealthyTable:
 *
 *   command = 0xDD
 */
static int asus_ec_write(uint8_t command, const uint8_t *payload, size_t len) {
  int ret;

  ret = drain_output();

  if (ret)
    return ret;

  ret = write_command(0xFF);

  if (ret)
    return ret;

  ret = write_command(command);

  if (ret)
    return ret;

  for (size_t i = 0; i < len; i++) {
    ret = write_data(payload[i]);

    if (ret)
      return ret;
  }

  return wait_ibf_clear();
}

/* ============================================================
 * ASUS HealthyTable functions
 * ============================================================ */

/*
 * HealthyTable_SetFanIndex(0)
 *
 * EC transaction:
 *
 *   DD 82 32 00
 *
 * Testing showed that fan index 0 controls both physical fans
 * on this machine.
 */
static int healthy_table_set_fan_index(uint8_t index) {
  const uint8_t payload[] = {HEALTHY_TABLE_PREFIX, HEALTHY_TABLE_FAN_INDEX,
                             index};

  return asus_ec_write(ASUS_EC_COMMAND, payload, sizeof(payload));
}

/*
 * HealthyTable_SetFanTestMode()
 *
 * enabled = 1:
 *
 *   DD 82 31 01
 *
 * enabled = 0:
 *
 *   DD 82 31 00
 */
static int healthy_table_set_fan_test_mode(int enabled) {
  const uint8_t payload[] = {HEALTHY_TABLE_PREFIX, HEALTHY_TABLE_FAN_TEST_MODE,
                             enabled ? 0x01 : 0x00};

  return asus_ec_write(ASUS_EC_COMMAND, payload, sizeof(payload));
}

/*
 * HealthyTable_SetFanPwmDuty()
 *
 * EC transaction:
 *
 *   DD 82 35 XX
 *
 * XX = PWM duty, 0x00 - 0xFF.
 */
static int healthy_table_set_fan_pwm(uint8_t pwm) {
  const uint8_t payload[] = {HEALTHY_TABLE_PREFIX, HEALTHY_TABLE_FAN_PWM, pwm};

  return asus_ec_write(ASUS_EC_COMMAND, payload, sizeof(payload));
}

/* ============================================================
 * High-level fan control
 * ============================================================ */

static int set_fan_speed(unsigned int percent) {
  int ret;

  /*
   * Safety clamp.
   */
  if (percent > MAX_FAN_PERCENT) {
    fprintf(stderr,
            "WARNING: Requested fan speed is %u%%.\n"
            "Maximum allowed fan speed is %d%%.\n"
            "Clamping request to %d%%.\n\n",
            percent, MAX_FAN_PERCENT, MAX_FAN_PERCENT);

    percent = MAX_FAN_PERCENT;
  }

  /*
   * Convert:
   *
   *     0-100%
   *
   * to:
   *
   *     0-255
   *
   * Rounded to nearest integer.
   */
  uint8_t pwm = (uint8_t)((percent * 255U + 50U) / 100U);

  printf("Setting ASUS fan speed\n");
  printf("----------------------\n");
  printf("Fan index : 0\n");
  printf("Speed     : %u%%\n", percent);
  printf("PWM       : %u / 255 (0x%02X)\n\n", pwm, pwm);

  /*
   * Step 1:
   *
   * HealthyTable_SetFanIndex(0)
   *
   * DD 82 32 00
   */
  printf("[1/3] Selecting fan index 0\n");
  printf("      DD 82 32 00\n");

  ret = healthy_table_set_fan_index(0);

  if (ret)
    return ret;

  /*
   * Step 2:
   *
   * HealthyTable_SetFanTestMode(1)
   *
   * DD 82 31 01
   */
  printf("[2/3] Enabling manual/test mode\n");
  printf("      DD 82 31 01\n");

  ret = healthy_table_set_fan_test_mode(1);

  if (ret)
    return ret;

  /*
   * Step 3:
   *
   * HealthyTable_SetFanPwmDuty(pwm)
   *
   * DD 82 35 XX
   */
  printf("[3/3] Setting PWM\n");
  printf("      DD 82 35 %02X\n", pwm);

  ret = healthy_table_set_fan_pwm(pwm);

  if (ret) {
    /*
     * We entered manual mode but failed to set PWM.
     *
     * Try to give control back to the firmware.
     */
    fprintf(stderr, "\nPWM write failed. "
                    "Attempting to restore automatic control.\n");

    (void)healthy_table_set_fan_test_mode(0);

    return ret;
  }

  printf("\nFan speed set successfully.\n");

  return 0;
}

/*
 * Return fan control to ASUS firmware.
 */
static int set_fan_auto(void) {
  int ret;

  printf("Restoring automatic ASUS fan control...\n");

  /*
   * Select the working fan index first.
   */
  ret = healthy_table_set_fan_index(0);

  if (ret)
    return ret;

  /*
   * Disable FanTestMode.
   *
   * DD 82 31 00
   */
  ret = healthy_table_set_fan_test_mode(0);

  if (ret)
    return ret;

  printf("Automatic fan control restored.\n");

  return 0;
}

/* ============================================================
 * Error / usage
 * ============================================================ */

static void print_ec_error(const char *operation, int ret) {
  if (ret == -ETIMEDOUT) {
    fprintf(stderr, "ERROR: %s failed: EC timeout\n", operation);
  } else {
    fprintf(stderr, "ERROR: %s failed: %d\n", operation, ret);
  }
}

static void usage(const char *program) {
  fprintf(stderr,
          "ASUS EC Fan Control\n"
          "\n"
          "Usage:\n"
          "  sudo %s <percentage>\n"
          "  sudo %s auto\n"
          "\n"
          "Examples:\n"
          "  sudo %s 10\n"
          "  sudo %s 50\n"
          "  sudo %s 95\n"
          "  sudo %s 100\n"
          "  sudo %s auto\n"
          "\n"
          "Fan speeds above %d%% are automatically "
          "clamped to %d%%.\n",
          program, program, program, program, program, program, program,
          MAX_FAN_PERCENT, MAX_FAN_PERCENT);
}

/* ============================================================
 * main
 * ============================================================ */

int main(int argc, char **argv) {
  int ret;
  int exit_code = 1;

  if (argc != 2) {
    usage(argv[0]);
    return 1;
  }

  /*
   * Need permission for:
   *
   *   0x25C DATA
   *   0x25D STATUS / COMMAND
   *
   * Therefore request two consecutive ports starting
   * from 0x25C.
   */
  if (ioperm(EC_DATA, 2, 1) != 0) {
    perror("ioperm");

    fprintf(stderr,
            "This program must be run as root.\n"
            "Try:\n"
            "  sudo %s ...\n",
            argv[0]);

    return 1;
  }

  /* --------------------------------------------------------
   * AUTO MODE
   * -------------------------------------------------------- */

  if (strcmp(argv[1], "auto") == 0) {

    ret = set_fan_auto();

    if (ret) {
      print_ec_error("Restoring automatic fan control", ret);

      goto cleanup;
    }

    exit_code = 0;
    goto cleanup;
  }

  /* --------------------------------------------------------
   * MANUAL FAN SPEED
   * -------------------------------------------------------- */

  char *end = NULL;

  errno = 0;

  long requested_percent = strtol(argv[1], &end, 10);

  /*
   * Reject invalid strings such as:
   *
   *   abc
   *   50abc
   */
  if (errno != 0 || end == argv[1] || *end != '\0') {

    fprintf(stderr, "ERROR: Invalid fan percentage: \"%s\"\n\n", argv[1]);

    usage(argv[0]);

    goto cleanup;
  }

  /*
   * Negative values are invalid.
   */
  if (requested_percent < 0) {

    fprintf(stderr, "ERROR: Fan percentage cannot be negative.\n");

    goto cleanup;
  }

  /*
   * Protect conversion to unsigned int.
   *
   * We don't actually need to preserve enormous values
   * because anything above 95% will be clamped anyway.
   */
  unsigned int percent;

  if (requested_percent > MAX_FAN_PERCENT) {

    fprintf(stderr,
            "WARNING: You requested %ld%% fan speed.\n"
            "For safety, this program allows a maximum "
            "of %d%%.\n"
            "Using %d%% instead.\n\n",
            requested_percent, MAX_FAN_PERCENT, MAX_FAN_PERCENT);

    percent = MAX_FAN_PERCENT;

  } else {

    percent = (unsigned int)requested_percent;
  }

  ret = set_fan_speed(percent);

  if (ret) {
    print_ec_error("Setting fan speed", ret);

    goto cleanup;
  }

  exit_code = 0;

  /* ============================================================
   * Cleanup
   * ============================================================ */

cleanup:

  /*
   * Remove I/O permission before exiting.
   */
  if (ioperm(EC_DATA, 2, 0) != 0)
    perror("ioperm disable");

  return exit_code;
}
