{ lib, stdenv, fetchurl }:
stdenv.mkDerivation rec {
  pname = "contabo-cli";
  version = "1.3.0";
  src = fetchurl {
    url = "https://github.com/contabo/cntb/releases/download/v${version}/cntb_v${version}_Linux_x86_64.tar.gz";
    hash = "sha256-UvHdJup3+YsSrjwAx6syJQwdS8ZRaUaUE2LC47qUMlg=";
  };
  unpackPhase = ''
    tar -xf $src -C .
  '';
  installPhase = ''
    mkdir -p $out/bin
    cp cntb $out/bin
  '';
  meta = with lib; {
    description = "Contabo Command-Line Interface";
    license = licenses.gpl3;
    platforms = platforms.linux;
    homepage = "https://github.com/contabo/cntb";
    downloadPage = "https://github.com/contabo/cntb/releases";
  };
}
