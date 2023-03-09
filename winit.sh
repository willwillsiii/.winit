#!/bin/sh

# Change to winit directory.
# This assumes the script is still located
# in the root of the winit repository.
cd "$(dirname "$0")"

use_defaults () {

    run=true
    confirm=false
    overwrite=false
    revert=false
    verbosity=1

}

# This is used to parse arguments.
# TODO: perhaps use getopt(s) to do this.
while [ "$#" -ge 1 ]; do
    case "$1" in
        -q)
            verbosity=0
            ;;
        -d)
            use_defaults
            ;;
        -v)
            verbosity=2
            ;;
        -c)
            overwrite='confirm'
            ;;
        -f)
            overwrite=true
            ;;
        -s)
            run=false
            verbosity=2
            ;;
        -r)
            revert=true
            ;;
        # TODO: Add cases for various configurations of plugins
    esac
    shift
done

# Pass a command as an argument to this function.
# The command will not be executed if the run variable
# is set to false.
run_cmd () {

    CMD="$@"

    if ! [ "${run:-true}" = false ]; then
        $CMD
    fi

    if [ "${verbosity:-1}" -ge 2 ]; then
        echo $CMD
    fi

}

# Use this to echo based on the verbosity level.
say () {

    string="$@"

    if [ "${verbosity:-1}" -ge 1 ]; then
        echo "$string"
    fi

}

# This is used to generate backups of existing files
# that safelink would otherwise overwite.
backup () {

    suffix='.bak'
    num=''
    orig=$1
    back="${orig}${suffix}"

    while [ -e "$back" ]; do
        num=$((num + 1))
        back="${orig}${suffix}${num}"
    done

    run_cmd cp -i "$src" "$dest"

}

# TODO: rewrite to use backups function
safe_link () {

    src=$(realpath -s $1)
    dest=$(realpath -s $2)

    if [ -L "$dest" ]; then
        existing_src="$(readlink $dest)"
        if ! [ "$existing_src" = "$src" ]; then
            say "$dest currently linked to $existing_src"
            say "Linking $dest to $src ..."
            run_cmd ln -sf "$src" "$dest"
            say "$dest is now linked to $src"
        else
            say "$dest is already linked to $src"
        fi
    else
        say "No link found at $dest"
        # TODO: add more say commands for verbosity.
        run_cmd ln -sbf --suffix='.bak' "$src" "$dest"
    fi

}

# Use this to remove the links if the src and dest match
# given arguments.
# TODO: add functionality to reinstate backed up files
safe_link_revert () {

    src=$(realpath -s $1)
    dest=$(realpath -s $2)

    existing_src="$(readlink $dest)"

    # TODO: rewrite to be more explicit about existing files.
    if [ "$src" = "$existing_src" ]; then
        run_cmd rm "$dest"
    fi

}

if [ "$revert" = true ]; then
    safe_link_revert "./.ssh/config" "${HOME}/.ssh/config"
    safe_link_revert "./vim/vimrc" "${HOME}/.vimrc"
    safe_link_revert "./tmux/tmux.conf" "${HOME}/.tmux.conf"
    exit 0
fi

# TODO: rework to store these pairs in an iterable way
safe_link "./.ssh/config" "${HOME}/.ssh/config"
safe_link "./vim/vimrc" "${HOME}/.vimrc"
safe_link "./tmux/tmux.conf" "${HOME}/.tmux.conf"
# TODO: add ./vim/pack symlink creation

