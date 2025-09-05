#!/bin/bash

WALLPAPERDIR="/home/vinkel/Pictures/wallpapers"

WALLPAPER=$(ls $WALLPAPERDIR | shuf -n 1)

# Set the wallpaper with fading effect
xcalib -a -gc 1.2 -brightness 1.0 # Adjust gamma and brightness for fade out
feh --bg-scale "$WALLPAPERDIR/$WALLPAPER" # Set the new wallpaper
sleep 1 # Sleep for 1 second for the fade effect to be noticeable
xcalib -c # Reset the gamma and brightness
