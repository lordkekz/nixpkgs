{
  lib,
  stdenv,
  fetchFromGitHub,
  installShellFiles,
  cmake,
  libxslt,
  docbook_xsl_ns,
  libsForQt5,
  libusb1,
  yaml-cpp,
}:

let
  inherit (stdenv.hostPlatform) isLinux;
in

stdenv.mkDerivation rec {
  pname = "qdmr";
  version = "0.12.3";

  src = fetchFromGitHub {
    owner = "hmatuschek";
    repo = "qdmr";
    rev = "v${version}";
    hash = "sha256-rb59zbYpIziqXWTjTApWXnkcpRiAUIqPiInEJdsYd48=";
  };

  nativeBuildInputs = [
    cmake
    libxslt
    libsForQt5.wrapQtAppsHook
    installShellFiles
  ];

  buildInputs = [
    libusb1
    libsForQt5.qtlocation
    libsForQt5.qtserialport
    libsForQt5.qttools
    libsForQt5.qtbase
    yaml-cpp
  ];

  postPatch = lib.optionalString isLinux ''
    substituteInPlace doc/docbook_man.debian.xsl \
      --replace /usr/share/xml/docbook/stylesheet/docbook-xsl/manpages/docbook\.xsl ${docbook_xsl_ns}/xml/xsl/docbook/manpages/docbook.xsl
  '';

  cmakeFlags = [
    "-DBUILD_MAN=ON"
    "-DINSTALL_UDEV_RULES=OFF"
  ];

  postInstall = ''
    installManPage doc/dmrconf.1 doc/qdmr.1
    mkdir -p "$out/etc/udev/rules.d"
    cp ${src}/dist/99-qdmr.rules $out/etc/udev/rules.d/
  '';

  doInstallCheck = true;

  meta = {
    description = "GUI application and command line tool for programming DMR radios";
    homepage = "https://dm3mat.darc.de/qdmr/";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ _0x4A6F ];
    platforms = lib.platforms.linux;
  };
}
