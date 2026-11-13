{ config, lib, ... }:
{
  programs.difftastic.enable = true;

  # Home Manager allows only one of delta and difftastic to own git's diff
  # output. Delta is the pager, so difftastic is wired up as a difftool here
  # rather than through `programs.difftastic.git`.
  programs.git.settings = {
    diff.tool = "difftastic";
    difftool.difftastic.cmd = "${lib.getExe config.programs.difftastic.package} $LOCAL $REMOTE";
  };
}
