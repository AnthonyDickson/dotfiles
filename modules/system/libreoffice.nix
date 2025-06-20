{pkgs, ...}:
{
  environment.systemPackages = with pkgs; [
    libreoffice-still
    hunspell
    hunspellDicts.en-au
  ];
}
