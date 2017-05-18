{ stdenv, haskellPackages }:

let 
    hsenv = haskellPackages.ghcWithPackages (p: with p; [ fficxx-runtime fficxx ]);
in

stdenv.mkDerivation {
  name = "HUKB-src";
  buildInputs = [ hsenv ];
  src = ./.; 
  buildPhase = ''
    ghc HUKB-gen.hs
    ./HUKB-gen
  '';
  installPhase = ''
    mkdir -p $out
    cp -a HUKB/* $out
  '';

}