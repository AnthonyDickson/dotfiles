{pkgs, ...}:
{
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.displayManager.sddm.theme = "where_is_my_sddm_theme";

  environment.systemPackages = with pkgs; [
    # Catppuccin Mocha: https://github.com/catppuccin/where-is-my-sddm-theme/blob/main/themes/catppuccin-mocha.conf
    (where-is-my-sddm-theme.override {
      themeConfig.General = {
        backgroundFill = "#1e1e2e";
        basicTextColor = "#cdd6f4";
        passwordCursorColor = "#cdd6f4";
        passwordInputBackground = "#1e1e2e";
        passwordTextColor = "#cdd6f4";
      };
    })
  ];
}
