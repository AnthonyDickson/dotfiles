{
  services.gnome.gnome-keyring.enable = true;
  # cosmic-greeter signs in through greetd
  security.pam.services.greetd.enableGnomeKeyring = true;
  security.pam.services.login.enableGnomeKeyring = true;
}
