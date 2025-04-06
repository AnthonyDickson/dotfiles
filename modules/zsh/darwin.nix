{
  imports = [
    ./default.nix
  ];

  # The better Bash
  programs.zsh = {
    initExtra = ''
      # alt + left arrow
      bindkey "^[[1;3D" backward-word
      # alt + right arrow
      bindkey "^[[1;3C" forward-word
      # delete key
      bindkey "^[[3~" delete-char
      # alt + del
      bindkey "^[[3;3~" delete-word

      # Fix for OCS 52 key codes (remote copy and paste) in kitty terminal
      # when using ssh.
      [[ "$TERM"  == "xterm-kitty" ]] && alias ssh="TERM=xterm-256color ssh"

      # Set config home used by lazygit
      export XDG_CONFIG_HOME="$HOME/.config"

      export EDITOR="nvim"
    '';
  };
}
