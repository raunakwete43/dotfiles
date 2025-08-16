#!/bin/bash
swap=false; invert=false; monitor=0
fill_color='0.0,0.0,0.0,1.0'

show_help() {
  cat <<EOF
Usage: $(basename "$0") [OPTION]... [off]

Hyprland OLED dimmer shader (v0.3.0 - GLES3 compliant)

Options:
  -a x:y:w:h   Apply only in region (top-left coordinates)
  -i           Invert region (external area dims)
  -s           Swap pixel phase (toggle pattern)
  -m ID        Monitor ID (hyprctl monitors). Default 0
  -h           Show help

Argument:
  off          Disable shader
EOF
}

# Parse arguments
while getopts ":a:ism:h" opt; do
  case $opt in
    a) area=$OPTARG ;;
    s) swap=true ;;
    i) invert=true ;;
    m) monitor=$OPTARG ;;
    h) show_help; exit 0 ;;
    *) show_help >&2; exit 1 ;;
  esac
done
shift $((OPTIND-1))

# Handle 'off' command
if [[ $# -gt 0 && $1 == "off" ]]; then
  hyprctl keyword decoration:screen_shader ""
  exit 0
fi

# Generate shader
cat > /dev/shm/hyproled_shader.glsl <<EOF
#version 300 es
precision highp float;
in vec2 v_texcoord;
uniform sampler2D tex;
uniform int wl_output;
out vec4 fragColor;

void main() {
  vec4 orig = texture(tex, v_texcoord);
  if (wl_output != ${monitor}) {
    fragColor = orig;
    return;
  }
  
  vec2 fc = gl_FragCoord.xy;
  bool even = mod(fc.x + fc.y, 2.0) == 0.0;
  vec4 pixel = ${swap:-false} ? 
    (even ? vec4(${fill_color}) : orig) : 
    (even ? orig : vec4(${fill_color}));
EOF

# Add region logic if specified
if [[ -n $area ]]; then
  if [[ $area =~ ^([0-9]+):([0-9]+):([0-9]+):([0-9]+)$ ]]; then
    read x y w h <<< "${BASH_REMATCH[*]:1:4}"
    cat >> /dev/shm/hyproled_shader.glsl <<EOF
  vec2 size = textureSize(tex, 0);
  float y_user = size.y - fc.y; // Convert to top-left coords
  bool inRegion = (fc.x >= ${x}.0 && fc.x <= ${x}.0 + ${w}.0) &&
                 (y_user >= ${y}.0 && y_user <= ${y}.0 + ${h}.0);
  fragColor = ${invert:-false} ? 
    (inRegion ? orig : pixel) : 
    (inRegion ? pixel : orig);
EOF
  else
    echo "Invalid area format. Use x:y:w:h" >&2
    exit 1
  fi
else
  echo "  fragColor = pixel;" >> /dev/shm/hyproled_shader.glsl
fi

# Close shader
echo "}" >> /dev/shm/hyproled_shader.glsl

# Apply shader
hyprctl keyword decoration:screen_shader /dev/shm/hyproled_shader.glsl
