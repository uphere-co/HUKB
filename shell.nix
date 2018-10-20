{ pkgs ? import <nixpkgs> {}
, fficxxSrc ? builtins.fetchGit {
                url = "https://github.com/wavewave/fficxx";
                rev = "f6b00a53d03de024dbd1d18bdd94bb647ccbf465";
                ref = "master";
              }
}:

with pkgs;

let
  ukb = callPackage ./ukb.nix {};

  newHaskellPackages = haskellPackages.override {
                         overrides = self: super: {
                           "fficxx" = self.callCabal2nix "fficxx" (fficxxSrc + "/fficxx") {};
                           "fficxx-runtime" = self.callCabal2nix "fficxx-runtime" (fficxxSrc + "/fficxx-runtime") {};
                         };
                       };

  stdcxxNix = import (fficxxSrc + "/stdcxx-gen/default.nix") {
              inherit (pkgs) stdenv;
              haskellPackages = newHaskellPackages;
           };

  newHaskellPackagesFinal = haskellPackages.override {
                              overrides = self: super: {
                                "fficxx" = self.callCabal2nix "fficxx" (fficxxSrc + "/fficxx") {};
                                "fficxx-runtime" = self.callCabal2nix "fficxx-runtime" (fficxxSrc + "/fficxx-runtime") {};
                                "stdcxx" = self.callPackage stdcxxNix { };
                              };
                            };

  hsenv = newHaskellPackagesFinal.ghcWithPackages (p: with p; [
            fficxx
            fficxx-runtime
            stdcxx
            #haskell-src-exts
            cabal-install
          ]);
in

stdenv.mkDerivation {
  name = "HUKB-dev";
  buildInputs = [ ukb hsenv boost ];
}
