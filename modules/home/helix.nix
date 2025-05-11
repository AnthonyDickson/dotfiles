{
  programs.helix = {
    enable = true;
    defaultEditor = true;
    settings = {
      editor = {
        bufferline = "multiple";
        line-number = "relative";
        rulers = [80 120];
        cursor-shape = {
          insert = "bar";
        };
        statusline = {
          left = ["mode" "spinner" "version-control" "file-name" "read-only-indicator" "file-modification-indicator"];
          right = ["diagnostics" "selections" "register" "position" "total-line-numbers" "file-encoding"];
        };
        end-of-line-diagnostics = "hint";
        inline-diagnostics = {
          cursor-line = "error";
          other-lines = "disable";
        };
      };
      keys.normal = {
        "C-s" = ":w";
        space.q = ":q";
      };
    };
  };
}
