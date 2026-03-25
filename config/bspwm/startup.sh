#!/bin/bash
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8"

# ----------------------------------------------------
# Helper: launch app on a specific workspace
# Uses --one-shot so the rule fires once and clears
# ----------------------------------------------------
run_on_ws() {
    local class=$1
    local ws=$2
    shift 2
    bspc rule -a "$class" desktop="^$ws" focus=off --one-shot
    "$@" &
}

# ----------------------------------------------------
# Brave (two instances)
# Second instance needs a small delay — both share the
# same WM_CLASS so the first --one-shot rule would
# absorb both windows if launched simultaneously.
# ----------------------------------------------------
run_on_ws Brave-browser 1 brave
sleep 0.6

run_on_ws Brave-browser 2 brave --new-window

# ----------------------------------------------------
# TMUX SETUP
# ----------------------------------------------------
if ! tmux has-session -t Kitty 2>/dev/null; then
    tmux new-session -d -s Kitty -n Term
    tmux new-window -t Kitty -n nvim
    tmux send-keys -t Kitty:nvim "lnt && nvim" C-m
fi
tmux select-window -t Kitty:Term

if ! tmux has-session -t Home 2>/dev/null; then
    tmux new-session -d -s Home -n Yazi
    tmux send-keys -t Home:Yazi "yazi" C-m
fi

run_on_ws kitty 3 kitty sh -c "tmux attach-session -t Kitty"

# ----------------------------------------------------
# File Manager + Super Productivity
# ----------------------------------------------------
run_on_ws org.gnome.Nautilus 5 nautilus

run_on_ws superProductivity 1 \
    flatpak run com.super_productivity.SuperProductivity

# ----------------------------------------------------
# Done
# ----------------------------------------------------
sleep 2 && bspc desktop -f 1 && notify-send "Welcome back, Dhanush 👋" "All Set... You're Ready to go!" &
