if status is-interactive
    # Commands to run in interactive sessions can go here
end

fish_add_path /bin/nvim/bin
fish_add_path /usr/local/bin/visualvm/bin
fish_add_path /usr/local/bin/odin
fish_add_path /usr/local/bin/ols
fish_add_path /usr/local/bin/c3c

set fish_color_valid_path
set -Ux JAVA_HOME /usr/lib/jvm/openjdk-21
set -Ux SUDO_EDITOR nvim
set -Ux EDITOR nvim

zoxide init fish | source

function jdgui
    java -jar /usr/local/bin/jars/jdgui.jar $argv & disown
end
