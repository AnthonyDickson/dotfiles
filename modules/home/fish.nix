{pkgs, config, ...}:
{
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting # Disable greeting

      # >>> mamba initialize >>>
      # !! Contents within this block are managed by 'mamba init' !!
      set -gx MAMBA_EXE "${pkgs.micromamba}/bin/micromamba"
      set -gx MAMBA_ROOT_PREFIX "${config.home.homeDirectory}/.micromamba"
      $MAMBA_EXE shell hook --shell fish --root-prefix $MAMBA_ROOT_PREFIX | source
      # <<< mamba initialize <<<

      # Autocomplete for Python package and project manager
      uv generate-shell-completion fish | source
      uvx generate-shell-completion fish | source
     '';
    shellAbbrs = {
      l = "lsd";
      lg = "lazygit";
      sg = "ast-grep";
      mm = "micromamba";
    };
  };
}
