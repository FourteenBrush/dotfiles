if status is-interactive
    # Commands to run in interactive sessions can go here
end

if not set -q SSH_AUTH_SOCK or not test -e $SSH_AUTH_SOCK
  eval (ssh-agent -c) > /dev/null
  ssh-add ~/.ssh/id_ed25519_git_personal_auth    2>/dev/null
  ssh-add ~/.ssh/id_ed25519_git_personal_signing 2>/dev/null
end

if test $XDG_SESSION_TYPE = "wayland"
  set -x MOZ_ENABLE_WAYLAND 1
end

set fish_color_valid_path
set fish_greeting

set -Ux SUDO_EDITOR nvim
set -Ux EDITOR nvim
set -x MANPAGER "nvim +Man!"

set -l java_home /usr/lib64/jvm/java-21-openjdk-21
if test -d $java_home
  set -x JAVA_HOME $java_home
end
set -x ANDROID_HOME ~/Android/Sdk

fish_vi_key_bindings
zoxide init fish | source

alias b bluetoothctl
alias p3 python3
alias hyprpicker="hyprpicker | tail -1 | tr -d '\n' | wl-copy"

abbr gc "git commit"
abbr gcm 'git commit -m "'

function font-picker
  set -l font (fc-list : family | sort -u | fzf)
  if test -n "$font"
    echo "$font" | tee /dev/tty | wl-copy
  end
end
