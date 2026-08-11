if status is-interactive
    # Commands to run in interactive sessions can go here
end

# ensure only one ssh-agent gets started by using a fixed socket path and checking for its existence
# an eval (ssh-agent -c) performs some setenv SSH_AUTH_SOCK=something call, which does not export
# this variable to other shells, therefore we cannot rely on a test -e "$SSH_AUTH_SOCK" alone
set -l ssh_agent_socket "$HOME/.ssh/agent.sock"

if not test -S "$ssh_agent_socket"; or not SSH_AUTH_SOCK="$ssh_agent_socket" ssh-add -l >/dev/null 2>&1
    rm -f "$ssh_agent_socket"
    eval (ssh-agent -c -a "$ssh_agent_socket") >/dev/null
end

set -gx SSH_AUTH_SOCK "$ssh_agent_socket"

if not ssh-add -l >/dev/null 2>&1
  ssh-add ~/.ssh/id_ed25519_git_personal_auth    2>/dev/null
  ssh-add ~/.ssh/id_ed25519_git_personal_signing 2>/dev/null
  ssh-add ~/.ssh/id_ed25519_git_college_auth     2>/dev/null
  ssh-add ~/.ssh/id_ed25519_git_college_signing  2>/dev/null
  ssh-add ~/.ssh/id_ed25519_ssh_auth             2>/dev/null
end

if test $XDG_SESSION_TYPE = "wayland"
  set -x MOZ_ENABLE_WAYLAND 1
end

set fish_color_valid_path
set fish_greeting

set -Ux SUDO_EDITOR nvim
set -Ux EDITOR nvim
set -x MANPAGER "nvim +Man!"
set -x ODIN_ROOT (odin root)

set -x XDG_VIDEOS_DIR ~/Pictures/Videos

set -l java_home /usr/lib64/jvm/java-25-openjdk-25/
if test -d $java_home
  set -x JAVA_HOME $java_home
end
set -x ANDROID_HOME ~/Android/Sdk

# add programs installed with 'nix profile add' to PATH
fish_add_path ~/.nix-profile/bin

fish_vi_key_bindings
zoxide init fish | source
# devbox completion fish | source

alias b bluetoothctl
alias p3 python3
alias hyprpicker="hyprpicker | tail -1 | tr -d '\n' | wl-copy"
alias bat "bat --theme TwoDark --no-paging"

abbr sysu "systemctl --user"

function picker
  set file (fzf)
  if test $status -eq 0
    nvim "$file"
  end
end

function p3eval
    p3 -c "print($argv)"
end

function threads
  set pid (pidof $argv[1])
  if test $status -ne 0
    echo "pidof $argv[1]: no pid found"
  end
  
  for thread in /proc/$pid/task/*
    bat $thread/comm
  end
end

abbr zy "sudo zypper --no-refresh --non-interactive in"

abbr gc "git commit"
abbr gcm 'git commit -m "'
abbr gs 'git status'

function font-picker
  set -l font (fc-list : family | sort -u | fzf)
  if test -n "$font"
    echo "$font" | tee /dev/tty | wl-copy
  end
end
