#!/usr/bin/env fish

# If multiple media clients are running, the first may be paused.
# Therefore, we should search for the player that is playing.
set player_statuses $(playerctl status --all-players 2>&1)
set players $(playerctl --list-all 2>&1)

if test "$player_statuses" = "No players found"
    return 1
end

for i in (seq (count $players))
    set player_status $player_statuses[$i]

    if test $player_status = Playing
        set player $players[$i]
        break
    end
end

# No playing media found
if test -z $player
    return 1
end

echo $player
