{ mkDerivation, base, HUKB, optparse-applicative, stdenv }:
mkDerivation {
  pname = "HUKB-driver";
  version = "0.1.0.0";
  src = ./.;
  isLibrary = true;
  isExecutable = true;
  libraryHaskellDepends = [ base HUKB ];
  executableHaskellDepends = [ base optparse-applicative ];
  license = stdenv.lib.licenses.unfree;
}
