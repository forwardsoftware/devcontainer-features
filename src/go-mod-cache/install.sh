#!/bin/sh
set -e

echo "Activating feature 'go-mod-cache'"

USERNAME=${USERNAME:-${_REMOTE_USER}}
GOPATH=${GOPATH:-/go}

create_cache_dir() {
    local cache_dir=$1
    local username=$2

    if [ -d "$cache_dir" ]; then
        echo "Cache directory $cache_dir already exists. Skip creation..."
    else
        echo "Create cache directory $cache_dir..."
        mkdir -p "$cache_dir"
    fi

    if ! getent group golang > /dev/null; then
        echo "Group 'golang' does not exist. Creating..."
        groupadd golang
    else
        echo "Group 'golang' already exists. Skip creation..."
    fi

    if [ -z "$username" ]; then
        echo "No username provided. Skip chown..."
    else
        echo "Change owner of $cache_dir to $username..."
        chown -R "$username:golang" "$cache_dir"
    fi
}

create_symlink_dir() {
    local local_dir=$1
    local cache_dir=$2
    local username=$3

    runuser -u "$username" -- mkdir -p "$(dirname "$local_dir")"
    runuser -u "$username" -- mkdir -p "$cache_dir"

    # if the folder we want to symlink already exists, the ln -s command will create a folder inside the existing folder
    if [ -e "$local_dir" ]; then
        echo "Moving existing $local_dir folder to $local_dir-old"
        mv "$local_dir" "$local_dir-old"
    fi

    echo "Symlink $local_dir to $cache_dir for $username..."
    runuser -u "$username" -- ln -s "$cache_dir" "$local_dir"
}

create_cache_dir "/mnt/go-cache" "${USERNAME}"
create_symlink_dir "$GOPATH/pkg" "/mnt/go-cache" "${USERNAME}"

echo "Finished installing 'go-mod-cache'"