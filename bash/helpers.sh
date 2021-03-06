#!/bin/bash
###############################################################################
# Author: Travis Goldie
# Purpose: Generic bash script helper functions
###############################################################################
##
# Header line:
#
# CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# source "$CURRENT_DIR/helpers.sh"
# trap cleanup SIGINT SIGTERM
##

##
# @description
# Runs default cleanup function. Use in a trap on signals
#
# ``` bash
# trap cleanup SIGINT SIGTERM
# ```
##
cleanup()
{
    echo "#### Trapped in $( basename $0 ). Exiting."
    exit 255
}

##
# @description
# Checks to see if error code is non-zero. If so, echo message and exit
# with the given error code.
#
# ``` bash
# $ someCmd blah blah2
# $ err=$?
# $ die $err "If err is non-zero this script will exit"
# ```
##
die()
{
    local err=$1
    local msg=$2
    local name=$( basename $0 )
    if [[ $err != 0 ]] ; then
        echo "[ERROR]:${name}:code $err:${msg}"
        exit $err
    fi
}

##
# @description
# Code snippet to check if script is being sourced in. If return
# is 0 then the script was sourced (bash command `source`.
#
# ``` bash
# # ... include copy of definition
#
# [[ is_sourced ]] && "Do one" || "Else this"
# ```
##
is_sourced()
{
    test "${BASH_SOURCE[0]}" != "${0}"
    return $?
}

##
# @param {string} session Name of the session to check or create
# @param {string} config The path to the config file to use
# @description
# Checks if the given session exists, and if so attaches to it,
# otherwise creates a new session using `config`
#
# Echos "new" if new session created or "attached" if attached
##
tmux_new_or_attach()
{
    local session=$1
    local config=$2

    echo HERE $session $config

    tmux has-session -t "$session" > /dev/null 2>&1
    should_attach=$?

    if [[ "$should_attach" == 0 ]] ; then
        tmux attach-session -t "$session"
        echo "Attached to {$session}"
    else
        tmux -f "$config" new-session -d -s "$session"
        echo "new session {$session} using config: {$config}"
    fi
}

##
# @param {string} session Name of the session to check or create
# @description
# Echo message and then attaches to session `$session`.
#
# Echos "new" if new session created or "attached" if attached
##
tmux_run_attach()
{
    local session=$1
    #export TMUX_SESSION=$session

    echo "Attaching to session: $session"
    tmux attach-session -t "$session"
}

#Tests if string ($1) contains the substring ($2)
contains ()
{
    [[ $# < 2 ]] && echo "Usage: contains \$string \$substring" >&2
    string=$1 ; substring=$2
    if test "${string#*$substring}" != "$string" ; then
        return 0    # $substring is in $string
    else
        return 1    # $substring is not in $string
    fi
}

#Case insensitive test if string ($1) contains the substring ($2)
icontains ()
{
    str=$( echo $1 | tr '[:upper:]' '[:lower:]' )
    substr=$( echo $2 | tr '[:upper:]' '[:lower:]' )
    return $( contains $str $substr )
}

##
# @name colors
# @description
# Print out colors with there names
##
colors ()
{
    for i in {0..255} ; do
        printf "\x1b[38;5;${i}mcolor${i}\n"
    done
}

