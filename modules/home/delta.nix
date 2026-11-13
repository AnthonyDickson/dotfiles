{ config, lib, ... }:
{
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      dark = true;
      line-numbers = true;
      syntax-theme = "Catppuccin Mocha";
    };
  };

  # Lazygit renders diffs itself and ignores git's pager settings, so it needs
  # to be pointed at delta separately. Delta still reads its options from the
  # `[delta]` section of the git config. The hyperlinks are set here rather
  # than there because `lazygit-edit://` links only work inside lazygit, where
  # clicking a line number opens that line in the editor.
  programs.lazygit.settings.git.diffRenderers = [
    {
      command = lib.concatStringsSep " " [
        (lib.getExe config.programs.delta.package)
        "--paging=never"
        "--hyperlinks"
        ''--hyperlinks-file-link-format="lazygit-edit://{path}:{line}"''
      ];
    }
  ];
}
