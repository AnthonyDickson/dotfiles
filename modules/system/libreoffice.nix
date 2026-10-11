{pkgs, ...}:
{
  environment.systemPackages = with pkgs; [
    libreoffice-stable
    hunspell
    hunspellDicts.en-au
  ];
}
