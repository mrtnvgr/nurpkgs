# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> { } }:
let
  p = pkgs.callPackage;
in rec {
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  # Soundfonts
  soundfont-arachno = p ./pkgs/soundfonts/arachno.nix { };
  soundfont-touhou = p ./pkgs/soundfonts/touhou.nix { };

  # Games
  celeste-classic = p ./pkgs/games/celeste-classic.nix { };

  # Hotfixes
  # Updates libvterm to v0.3.3 for neovim nightly
  # NOTE: https://github.com/nix-community/neovim-nightly-overlay/issues/332
  libvterm-neovim = p ./pkgs/hotfixes/libvterm-neovim.nix { };
}
