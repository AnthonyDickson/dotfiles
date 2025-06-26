{pkgs, ...}:
{
  environment.systemPackages = with pkgs; [
    wordbook
  ];
}
