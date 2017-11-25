{ pkgs ? import <nixpkgs> {}
, uphere-nix-overlay ? <uphere-nix-overlay>
, HWordNet           ? <HWordNet>
, nlp-types          ? <nlp-types>
}:

with pkgs;

let
  ukb = import (uphere-nix-overlay + "/nix/cpp-modules/ukb.nix") { inherit stdenv fetchgit fetchurl boost; };
  hsconfig = import (uphere-nix-overlay + "/nix/haskell-modules/configuration-ghc-8.0.x.nix") {
    inherit pkgs;
  };

  newconfig = import ./config.nix { inherit pkgs uphere-nix-overlay ukb; };

  hsconfig2 =
    self: super: {
      "HWordNet"  = self.callPackage (import HWordNet)  {};
      "nlp-types" = self.callPackage (import nlp-types) {};
    };

  newHaskellPkgs = haskellPackages.override {
    overrides = self: super: hsconfig self super // hsconfig2 self super // newconfig self super;
  };

  hsenv = newHaskellPkgs.ghcWithPackages (p: with p; [
            fficxx
            fficxx-runtime
            optparse-applicative
            taggy-lens
            text
            p.HUKB
            p.HWordNet
          ]);
in

stdenv.mkDerivation {
  name = "HUKB-dev";
  buildInputs = [ hsenv ukb boost ];
  shellHook = ''
    export LD_LIBRARY_PATH=${boost}/lib:${ukb}/lib
  '';
}

