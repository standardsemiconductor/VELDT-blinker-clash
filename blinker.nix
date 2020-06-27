{ mkDerivation, base, clash-ghc, clash-prelude, filepath
, interpolate, mtl, stdenv
}:
mkDerivation {
  pname = "blinker";
  version = "0.1.0.0";
  src = ./.;
  libraryHaskellDepends = [
    base clash-ghc clash-prelude filepath interpolate mtl
  ];
  description = "VELDT Led Blinker";
  license = "unknown";
  hydraPlatforms = stdenv.lib.platforms.none;
}
