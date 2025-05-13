{
  programs.helix = {
    enable = true;
    defaultEditor = true;
    settings = {
      theme = "catppuccin_mocha";
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
        indent-guides = {
          render = true;
          character = "▏";
          skip-levels = 1;
        };
      };
      keys.normal = {
        "C-s" = ":w";
        space.q = ":q";
      };
      languages = {
        lanaguage = [
          {
            name = "python";
            language-servers = ["pyright" "ruff"];
          }
        ];

        language-server = {
          pyright.config.python.analysis.typeCheckingMode = "basic";
          ruff = {
            command = "ruff";
            args = ["server"];
          };
        };
      };
    };
  };
}
