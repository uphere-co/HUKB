{ pkgs ? import <nixpkgs> {}
, uphere-nix-overlay ? <uphere-nix-overlay>
}:

with pkgs;

let
  hsenv = haskellPackages.ghcWithPackages (p: with p; [
            taggy-lens
            text
          ]);
  ukb = import (uphere-nix-overlay + "/nix/cpp-modules/ukb.nix") { inherit stdenv fetchgit fetchurl boost; };
in

stdenv.mkDerivation {
  name = "HUKB-dev";
  buildInputs = [ hsenv ukb ];
  shellHook = ''
  '';
}

