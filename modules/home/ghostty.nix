{
  programs.ghostty = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      mouse-scroll-multiplier = 0.5;
      shell-integration-features = "ssh-terminfo,ssh-env";
    };
  };
}
