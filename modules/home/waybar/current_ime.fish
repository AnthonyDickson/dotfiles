#!/usr/bin/env fish
set CURRENT_IME $(dbus-send --session --print-reply \
                    --dest=org.fcitx.Fcitx5 \
                    /controller \
                    org.fcitx.Fcitx.Controller1.CurrentInputMethod \
                    | grep -Po '(?<=")[^"]+')

switch $CURRENT_IME
    case keyboard-us
        echo EN 🇳🇿
    case rime
        echo ZH 🇨🇳
    case mozc
        echo JA 🇯🇵
    case '*'
        echo $CURRENT_IME
end
