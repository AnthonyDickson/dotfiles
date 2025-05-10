{pkgs, ...}:
let
  yaziFlavors = pkgs.fetchFromGitHub {
    owner = "yazi-rs";
    repo = "flavors";
    rev = "68326b4ca4b5b66da3d4a4cce3050e5e950aade5";
    hash = "sha256-nhIhCMBqr4VSzesplQRF6Ik55b3Ljae0dN+TYbzQb5s=";
  };
  theme = "catppuccin-mocha";
in
{
  programs.yazi = {
    enable = true;
    enableFishIntegration = true;
    flavors = {
      ${theme} = "${yaziFlavors}/${theme}.yazi";
    };
    theme = {
      flavor = {
        light = "${theme}";
        dark = "${theme}";
      };
    };
  };
}
