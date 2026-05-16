{
  lib,
  pkgs,
  appimageTools,
  fetchurl,
  runCommand,
  unzip,
}:
let
  pname = "eveguru";
  version = "latest";
  downloaded = fetchurl {
    url = "https://drive.usercontent.google.com/download?id=1PgDef_Njr-rPZrEwDFv3w9h9HFDHfIPZ&export=download&confirm=t";
    hash = "sha256-dUtgJhv4Ib8AD6vXY1t5ylIHpPFgmmv5ov8gilxuT/I=";
  };
  src = runCommand "eveguru-appimage" { buildInputs = [ unzip ]; } ''
    unzip ${downloaded} EveGuruLinux-x86_64.AppImage
    mv EveGuruLinux-x86_64.AppImage $out
  '';
  appimageContents = appimageTools.extractType2 { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;
  extraPkgs = pkgs: [ pkgs.unzip pkgs.python3 ];
  extraInstallCommands = ''
    install -Dm444 ${appimageContents}/eveguru.desktop \
      $out/share/applications/eveguru.desktop || true
    cp -r ${appimageContents}/usr/share/icons $out/share/ 2>/dev/null || true
  '';
  meta = {
    description = "EVE Online manufacturing and trading tool";
    homepage = "https://eveguru.online";
    license = lib.licenses.unfree;
    mainProgram = "eveguru";
    platforms = [ "x86_64-linux" ];
  };
}
