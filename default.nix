{ nixpkgs ? import <nixpkgs> {} }:

let
  inherit (nixpkgs) pkgs;
  myTex = with pkgs; texlive.combine {
    inherit (texlive) scheme-small dvisvgm amsfonts pdfcrop stmaryrd;
  };

in pkgs.mkShell {
  name = "env";
  buildInputs = with pkgs; [
    ghostscript
    imagemagick
    myTex
  ];
}
