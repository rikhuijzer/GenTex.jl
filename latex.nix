{ nixpkgs ? import <nixpkgs> {} }:

let
  # Pinning explicitly to 20.03.
  rev = "cd63096d6d887d689543a0b97743d28995bc9bc3";
  nixpkgs = fetchTarball "https://github.com/NixOS/nixpkgs/archive/${rev}.tar.gz";
  pkgs = import nixpkgs {};
  myTex = with pkgs; texlive.combine {
    inherit (texlive) scheme-basic dvisvgm amsfonts pdfcrop stmaryrd;
  };
in [
  myTex
]
