{
  programs.helix = {
    enable = true;
    defaultEditor = true;
    settings = {
      theme = "catppuccin_mocha";
      editor = {
        bufferline = "multiple";
        line-number = "relative";
        rulers = [
          80
          120
        ];
        cursor-shape = {
          insert = "bar";
        };
        statusline = {
          left = [
            "mode"
            "spinner"
            "version-control"
            "file-name"
            "read-only-indicator"
            "file-modification-indicator"
          ];
          right = [
            "diagnostics"
            "selections"
            "register"
            "position"
            "total-line-numbers"
            "file-encoding"
          ];
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
    };
    languages = {
      language = [
        {
          name = "python";
          language-servers = [
            "pyright"
            "ruff"
          ];
        }
        {
          name = "markdown";
          formatter = {
            command = "dprint";
            args = [
              "fmt"
              "--config"
              ./dprint.json
              "--stdin"
              "md"
            ];
          };
          rulers = [ 120 ];
        }
      ];

      language-server = {
        pyright.config.python.analysis.typeCheckingMode = "basic";
        ruff = {
          command = "ruff";
          args = [ "server" ];
        };
        tinymist = {
          command = "tinymist";
          config = {
            exportPdf = "onType";
            outputPath = "$root/target/$dir/$name";
            preview.background = {
              enabled = true;
              args = [
                "--data-plane-host=127.0.0.1:23635"
                "--invert-colors=never"
                "--open"
              ];
            };
          };
        };
      };
    };
  };
}
