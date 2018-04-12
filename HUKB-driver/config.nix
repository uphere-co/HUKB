{ pkgs ? import <nixpkgs> {}
, uphere-nix-overlay ? <uphere-nix-overlay>
, ukb
, haskellLib
}:

with pkgs;

let
  hsconfig = import (uphere-nix-overlay + "/nix/haskell-modules/configuration-ghc-8.2.x.nix") { inherit pkgs haskellLib; };
  haskellPackages1 = haskellPackages.override { overrides = hsconfig; };
  HUKBnix = import ../HUKB-generate/default.nix {
    inherit stdenv;
    haskellPackages = haskellPackages1;
  };
in self: super: {
     HUKB =  self.callPackage HUKBnix { inherit boost ukb; };  
   }


