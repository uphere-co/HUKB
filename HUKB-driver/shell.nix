{ pkgs ? import <nixpkgs> {}
, uphere-nix-overlay ? <uphere-nix-overlay>
}:

with pkgs;

let
  ukb = import (uphere-nix-overlay + "/nix/cpp-modules/ukb.nix") { inherit stdenv fetchgit fetchurl boost; };

  hsconfig = import (uphere-nix-overlay + "/nix/haskell-modules/configuration-ghc-8.0.x.nix") { inherit pkgs; };
  hsconfig2 =
    let haskellPackages1 = haskellPackages.override { overrides = hsconfig; };
        HUKBnix = import ../HUKB-generate/default.nix {
          inherit stdenv;
          haskellPackages = haskellPackages1;
        };
    in self: super: {
         HUKB =  self.callPackage HUKBnix { inherit boost ukb; };  
       }; 
  newHaskellPkgs = haskellPackages.override {
    overrides = self: super: hsconfig self super // hsconfig2 self super;

  };
  hsenv = newHaskellPkgs.ghcWithPackages (p: with p; [
            fficxx
            fficxx-runtime
            optparse-applicative
            taggy-lens
            text
            HUKB
          ]);
in

stdenv.mkDerivation {
  name = "HUKB-dev";
  buildInputs = [ hsenv ukb boost ];
  shellHook = ''
    export LD_LIBRARY_PATH=${boost}/lib:${ukb}/lib
  '';
}

