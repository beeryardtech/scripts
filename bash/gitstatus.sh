#!/bin/bash
###############################################################################
# Author: Travis Goldie
# Purpose: Runs git status and diff in vimui tmux session
###############################################################################

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$CURRENT_DIR/helpers.sh"
trap cleanup SIGINT SIGTERM

ARG1=$1
SESSION="vimui"
PWD=${ARG1:-~/ui}
CD="cd $PWD"
WINDOW=1

respawn_pane()
{
    # Respawn panes (-k kills current commands)
    tmux respawn-pane -k -t "$SESSION:${WINDOW}.0"
    tmux respawn-pane -k -t "$SESSION:${WINDOW}.1"
    tmux respawn-pane -k -t "$SESSION:${WINDOW}.2"
}

send_keys()
{
    local gitAdd="git add"
    local gitDiff="$CD ; git diff"
    local gitStatus="$CD ; git status"

    # Send keys
    tmux send-keys -t "$SESSION:${WINDOW}.0" "$gitStatus" C-m
    tmux send-keys -t "$SESSION:${WINDOW}.1" "$gitDiff" C-m
    tmux send-keys -t "$SESSION:${WINDOW}.2" "$CD" C-m
}

select_window()
{
    tmux select-window -t "$SESSION:${WINDOW}"
}

main()
{
    respawn_pane
    send_keys
    select_window
}
main
