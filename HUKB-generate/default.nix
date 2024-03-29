{ stdenv, haskellPackages }:

let
  HUKB-src = import ./gen.nix { inherit stdenv haskellPackages; };
in 

{ mkDerivation, base 
, fficxx, fficxx-runtime, stdenv, template-haskell, stdcxx
, boost, ukb
}:
mkDerivation {
  pname = "HUKB";
  version = "0.0";
  src = HUKB-src;
  libraryHaskellDepends = [
    base fficxx fficxx-runtime template-haskell stdcxx
  ];
  librarySystemDepends = [ boost ukb ];
  license = stdenv.lib.licenses.bsd3;
}
