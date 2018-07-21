{ pkgs ? import <nixpkgs> {}

#? import (builtins.fetchGit {
#    url = "https://github.com/wavewave/nixpkgs.git";
#    rev = "b897bf4f3cd3bb4a1077c096043e20b4fceaef0c";
##    ref = "master";
#  }) {}
}:

with pkgs;

let
  ukb = callPackage ./ukb.nix {};

  fficxxSrc = fetchgit {
                url = "https://github.com/wavewave/fficxx";
                rev = "020871332cbefd135ce7380a04fbdc93e3f8254b";
                sha256 = "01m2765dwsh3xm96jbxy75rgbxj8jspx6ypkh07gns43daqds1dc";
              };

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
