{ pkgs ? import <nixpkgs> {}
, uphere-nix-overlay ? <uphere-nix-overlay>
, ukb
}:

with pkgs;

let
  hsconfig = import (uphere-nix-overlay + "/nix/haskell-modules/configuration-ghc-8.0.x.nix") { inherit pkgs; };
  haskellPackages1 = haskellPackages.override { overrides = hsconfig; };
  HUKBnix = import ../HUKB-generate/default.nix {
    inherit stdenv;
    haskellPackages = haskellPackages1;
  };
in self: super: {
     HUKB =  self.callPackage HUKBnix { inherit boost ukb; };  
   }


