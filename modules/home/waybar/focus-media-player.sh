#!/usr/bin/env fish

set player $(get-current-player)

if test -z $player
  return
end

if string match "'/org/ncspot*" $(playerctl metadata mpris:trackid --player=$player)
  set title "ncspot"
else
  set title $(playerctl metadata xesam:title)
end

set window_addr $(hyprctl clients -j | jaq -r ".[] | select(.title | contains(\"$title\")).address")

if test -z $window_addr
  return
end

echo $window_addr

hyprctl dispatch focuswindow address:$window_addr
