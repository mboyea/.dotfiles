{ config, lib, pkgs, inputs, ... }: {
  nix.settings = {
    experimental-features = "nix-command flakes";
  };
}

