{pkgs, ...}:
{
  environment.systemPackages = with pkgs; [
    # Markdown LSP + wiki style links
    marksman
  ];
}
