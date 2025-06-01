#!/etc/profiles/per-user/anthony/bin/fish

# NOTE: This script will not work if you open kitty and the ncspot, it will
#  only work if you run ncspot from walker.
set TARGET_WINDOW_PID $(hyprctl -j clients | jaq '.[] | select(.title == "ncspot") | .pid')

# -z returns true if the operand expands to an empty string
if test -z $TARGET_WINDOW_PID
  return
end

hyprctl dispatch focuswindow pid:$TARGET_WINDOW_PID
