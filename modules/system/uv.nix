{pkgs, ...}:
{
  environment.systemPackages = [
    # A venv manager for Python, written in rust 🦀
    pkgs.uv
  ];
}
