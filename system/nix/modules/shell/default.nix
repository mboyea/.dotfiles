{ config, lib, pkgs, inputs, ... }: {
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    shellInit = ''export ZDOTDIR="$HOME/.zsh"'';
    histFile = "$ZDOTDIR/.zsh_history";
  };

  users.defaultUserShell = pkgs.zsh;
}

