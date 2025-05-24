#!/etc/profiles/per-user/anthony/bin/fish
set OUTPUT $(nc -W 1 -U /run/user/$(id -u $(whoami))/ncspot/ncspot.sock)
set MODE_TYPE $(echo $OUTPUT | jaq '.mode | type')

if test $MODE_TYPE = '"object"'
    set MODE $(echo $OUTPUT | jaq '.mode | keys | .[0]')
else
    set MODE $(echo $OUTPUT | jaq '.mode')
end

if test $MODE != '"Playing"'
    return
end

set DISPLAY $(echo $OUTPUT | jaq -r '"\(.playable.title) - \(.playable.artists | join(","))"')
echo $DISPLAY
