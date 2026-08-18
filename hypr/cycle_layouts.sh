#!/usr/bin/env bash

set -eu

current_layout=$(hyprctl activeworkspace -j | jq -r '.tiledLayout')
layouts=(dwindle master scrolling)

choice=$(
  {
    for layout in "${layouts[@]}"; do
      if [[ "$layout" != "$current_layout" ]]; then
        echo "${layout^}"
      fi
    done

    echo "${current_layout^} (Current)"
  } |
  vicinae dmenu -p "Select Layout" --no-footer --height 400
)

# eval call expects lowercase layout string
layout=$(echo "${choice,}" | sed 's/ (Current)//')
echo $layout

hyprctl eval "hl.workspace_rule { workspace = tostring(hl.get_active_workspace().name), layout='$layout' }"

notify-send "Switched to layout $layout" -t 1100
