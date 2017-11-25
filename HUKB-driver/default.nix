{ mkDerivation, base, bytestring, errors, lens, text, HWordNet, HUKB, optparse-applicative, stdenv }:
mkDerivation {
  pname = "HUKB-driver";
  version = "0.1.0.0";
  src = ./.;
  isLibrary = true;
  isExecutable = true;
  libraryHaskellDepends = [ base bytestring errors lens text HWordNet HUKB ];
  executableHaskellDepends = [ base bytestring optparse-applicative text ];
  license = stdenv.lib.licenses.unfree;
}
