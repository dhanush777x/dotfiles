#!/usr/bin/env bash

# Get the main Spotify window ID
win=$(wmctrl -lx | grep -i 'spotify.Spotify' | awk '{print $1}')

if [ -z "$win" ]; then
    # Launch new Spotify tdrop scratchpad
    tdrop -w 70% -h 75% -x 15% -y 15% spotify
else
    # Check if window is mapped
    mapped=$(xwininfo -id "$win" | grep "Map State" | awk '{print $3}')

    # If hidden, temporarily show to move it
    if [ "$mapped" = "IsUnMapped" ]; then
        xdo show "$win"
        bspc node "$win" -d focused.desktop
        xdo hide "$win"
        mapped="IsMapped"  # mark as ready to toggle
    fi

    # Toggle visibility explicitly
    mapped=$(xwininfo -id "$win" | grep "Map State" | awk '{print $3}')
    if [ "$mapped" = "IsUnMapped" ]; then
        xdo show "$win"
    else
        xdo hide "$win"
    fi
fi
