#!/bin/sh

set -e

echo "Activating feature 'go-mod-cache'"

USERNAME=${USERNAME:-${_REMOTE_USER}}
GOPATH=${GOPATH:-/go}

setup_groups() {
    if ! getent group golang > /dev/null; then
        echo "Group 'golang' does not exist. Creating..."
        groupadd golang
    else
        echo "Group 'golang' already exists. Skip creation..."
    fi
}

create_dir() {
    local target_dir=$1
    local username=$2

    if [ -d "$target_dir" ]; then
        echo "Directory $target_dir already exists. Skip creation..."
    else
        echo "Create directory $target_dir..."
        mkdir -p "$target_dir"
    fi

    if [ -z "$username" ]; then
        echo "No username provided. Skip chown..."
    else
        echo "Change owner of $target_dir to $username..."
        chown -R "$username:golang" "$target_dir"
    fi
}

symlink_dirs() {
    local local_dir=$1
    local cache_dir=$2
    local username=$3

    # if the folder we want to symlink already exists, the ln -s command will create a folder inside the existing folder
    if [ -e "$local_dir" ]; then
        echo "Moving existing $local_dir folder to $local_dir-old"
        mv "$local_dir" "$local_dir-old"
    fi

    echo "Symlink $local_dir to $cache_dir for $username..."
    runuser -u "$username" -- ln -s "$cache_dir" "$local_dir"
}

setup_groups
create_dir "/mnt/go-cache" "${USERNAME}"
create_dir "$GOPATH" "${USERNAME}"
symlink_dirs "$GOPATH/pkg" "/mnt/go-cache" "${USERNAME}"

echo "Finished installing 'go-mod-cache'"