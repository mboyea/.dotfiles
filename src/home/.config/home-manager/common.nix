# This file declares overwrites for an existing home.nix file; fields that are pre-existing in the configuration like home.username and home.stateVersion are left intact.
{ config, lib, pkgs, inputs, ... }: {
  home.packages = with pkgs; [
  ];
  home.file = {
  };
  home.sessionVariables = {
    # EDITOR = "emacs";
  };
}

