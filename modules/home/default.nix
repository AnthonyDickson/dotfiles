# Home Manager modules shared by every host. Host-specific modules (e.g.
# kitty.nix, nerd-fonts.nix) are imported from the host's home.nix.
{
  imports = [
    ./cli-tools.nix
    ./delta.nix
    ./difftastic.nix
    ./fish.nix
    ./ghostty.nix
    ./git.nix
    ./helix.nix
    ./ssh.nix
    ./starship.nix
    ./stylix.nix
    ./yazi.nix
    ./zellij.nix
    ./zoxide.nix
  ];
}
