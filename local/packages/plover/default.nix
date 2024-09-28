# TODO: Make this actually work.
{ lib, appimageTools, fetchurl }:
let
  pname = "plover";
  version = "4.0.0rc2";
  src = fetchurl {
    url = "https://github.com/openstenoproject/plover/releases/download/v${version}/plover-${version}-x86_64.AppImage";
    hash = "";
  };

  appimageContents = appimageTools.extractType2 {
    inherit pname version src;
  };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    mv $out/bin/${pname}-${version} $out/bin/${pname}
    install -m 444 -D ${appimageContents}/plover.desktop $out/share/applications/plover.desktop
    install -m 444 -D ${appimageContents}/plover.png $out/share/icons/hicolor/128x128/apps/plover.desktop
  '';

  meta = with lib; {
    description = "Open source stenotype engine.";
    homepage = "http://opensteno.org/plover";
    license = licenses.gpl2;
    maintainers = [ ];
    platforms = [ "x86_64-linux" ];
  };
}
