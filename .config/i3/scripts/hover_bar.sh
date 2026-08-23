#!/bin/bash
# Monitors mouse position near top edge
# Shows polybar on approach, hides after cursor leaves

# Let polybar start first
sleep 2
polybar-msg cmd hide
visible=false
while true; do
    eval $(xdotool getmouselocation --shell 2>/dev/null)
    if [ "$Y" -le 3 ] 2>/dev/null && ! $visible; then
        polybar-msg cmd show; visible=true
    elif [ "$Y" -gt 3 ] 2>/dev/null && $visible; then
        polybar-msg cmd hide; visible=false
    fi
    sleep 0.1
done
