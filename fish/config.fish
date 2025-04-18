if status is-interactive
    # Commands to run in interactive sessions can go here
end

fish_add_path /bin/nvim/bin
fish_add_path /usr/local/bin/visualvm/bin
fish_add_path /usr/local/bin/odin
fish_add_path /usr/local/bin/ols
fish_add_path /usr/local/bin/c3c
fish_add_path /usr/local/bin/floorp

set fish_color_valid_path
set fish_greeting

set -Ux JAVA_HOME /usr/lib/jvm/java-21-openjdk-amd64
set -Ux SUDO_EDITOR nvim
set -Ux EDITOR nvim
set -Ux ODIN_ROOT (odin root)
set -x MANPAGER "nvim +Man!"

alias b bluetoothctl
abbr gc "git commit"
abbr gcm 'git commit -m "'

fish_vi_key_bindings

zoxide init fish | source

function jdgui
    java -jar /usr/local/bin/jars/jdgui.jar $argv & disown
end

function package_build_shell
    nix-shell -E "with import <nixpkgs> {}; callPackage $argv[1] {}"
end

function update_odin
    pushd .
    cd /usr/local/bin/odin
    git pull
    ./update_odin release-native

    cd /usr/local/bin/ols
    git pull
    ./build
    popd
    popd
end

alias bat batcat
