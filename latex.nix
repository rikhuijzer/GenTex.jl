{ nixpkgs ? import <nixpkgs> {} }:

let
  inherit (nixpkgs) pkgs;
  myTex = with pkgs; texlive.combine {
    inherit (texlive) scheme-basic dvisvgm amsfonts pdfcrop stmaryrd;
  };
in [
  myTex
]