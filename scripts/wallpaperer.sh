#!/bin/zsh
while true; do
  curl -s "$(osascript -e 'tell application "Spotify" to artwork url of current track')" -o /tmp/cover.jpg
  wallpaper set /tmp/cover.jpg
  sleep 30
done
