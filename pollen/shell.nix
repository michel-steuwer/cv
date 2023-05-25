{ pkgs ? import (fetchTarball "http://nixos.org/channels/nixos-22.11/nixexprs.tar.xz") {} }:

pkgs.mkShell {
  buildInputs = [
    pkgs.racket
  ];
}
