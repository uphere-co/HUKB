{ pkgs ? import <nixpkgs> {}
, uphere-nix-overlay ? <uphere-nix-overlay>
}:

with pkgs;

let
  hsconfig = import (uphere-nix-overlay + "/nix/haskell-modules/configuration-ghc-8.0.x.nix") { inherit pkgs; };
  newHaskellPkgs = haskellPackages.override { overrides = hsconfig; };
  hsenv = newHaskellPkgs.ghcWithPackages (p: with p; [
            fficxx
            fficxx-runtime
            optparse-applicative
            taggy-lens
            text
          ]);
  ukb = import (uphere-nix-overlay + "/nix/cpp-modules/ukb.nix") { inherit stdenv fetchgit fetchurl boost; };
in

stdenv.mkDerivation {
  name = "HUKB-dev";
  buildInputs = [ hsenv ukb boost ];
  shellHook = ''
    export LD_LIBRARY_PATH=${boost}/lib:${ukb}/lib
    export hsenv=${hsenv}
  '';
}

