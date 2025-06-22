#!/usr/bin/env fish

set player $(playerctl-current-player-get)

if test -z $player
    return
end

set title $(playerctl metadata xesam:title --player=$player)
set artist $(playerctl metadata xesam:artist --player=$player)
set url $(playerctl metadata xesam:url --player=$player)

switch $url
    case "*youtube.com*"
        set icon 󰗃
    case "*twitch.tv*"
        set icon 󰕃
    case "*spotify.com*"
        set icon 󰓇
    case "*jellyfin.mystash.dev*"
        set icon 󰼁
    case "*"
        set icon 󰐌
end

if test -z $artist
    echo "$icon $title"
else
    echo "$icon $title - $artist"
end
