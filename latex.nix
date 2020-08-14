{ nixpkgs ? import <nixpkgs> {} }:

let
  inherit (nixpkgs) pkgs;
  myTex = with pkgs; texlive.combine {
    inherit (texlive) scheme-minimal dvisvgm amsfonts pdfcrop stmaryrd;
  };
in [
  pkgs.ghostscript
  pkgs.imagemagick
  myTex
]
