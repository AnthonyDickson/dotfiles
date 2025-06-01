{pkgs, ...}:
{
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-color-emoji
      nerd-fonts.fira-code
    ];
    fontconfig = {
      defaultFonts= {
        serif = [ "Noto Serif" "Noto Serif CJK JP" "Noto Serif CJK SC" "Noto Serif CJK TC" "Noto Serif CJK KR" "FiraCode Nerd Font Propo"];
        sansSerif = [ "Noto Sans" "Noto Sans CJK JP" "Noto Sans CJK SC" "Noto Sans CJK TC" "Noto Sans CJK KR" "FiraCode Nerd Font Propo"];
        monospace = [ "Noto Mono" "Noto Mono CJK JP" "Noto Mono CJK SC" "Noto Mono CJK TC" "Noto Mono CJK KR" "FiraCode Nerd Font Mono"];
        emoji = ["Noto Color Emoji"];
      };
    };
  };
}
