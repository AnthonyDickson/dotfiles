{pkgs, config, ...}:
{
  home.packages = with pkgs; [
    micromamba
  ];

  programs.zsh = {
    shellAliases.mm = "micromamba";
    initContent = ''
    # >>> mamba initialize >>>
    # !! Contents within this block is managed by 'mamba init' !!
    export MAMBA_EXE='${pkgs.micromamba}/bin/micromamba';
    export MAMBA_ROOT_PREFIX='${config.home.homeDirectory}/.micromamba';
    __mamba_setup="$("$MAMBA_EXE" shell hook --shell zsh --root-prefix "$MAMBA_ROOT_PREFIX" 2> /dev/null)"
    if [ $? -eq 0 ]; then
      eval "$__mamba_setup"
    else
      alias micromamba="$MAMBA_EXE" # Fallback on help mamba activate
    fi
    unset __mamba_setup
    # <<< mamba initialize <<<
    micromamba config set changeps1 false
    '';
  };
}
