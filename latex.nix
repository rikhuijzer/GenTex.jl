{ nixpkgs ? import <nixpkgs> {} }:

let
  inherit (nixpkgs) pkgs;
  myTex = with pkgs; texlive.combine {
    inherit (texlive) scheme-minimal dvisvgm amsfonts pdfcrop stmaryrd;
  };
in [
  pkgs.imagemagick
  myTex
]
