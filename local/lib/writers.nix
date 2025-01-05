inputs@{
  nixpkgs,
  ...
}:
let
  pkgs = nixpkgs.legacyPackages.x86_64-linux;
  lib = pkgs.lib;
  
  inherit (pkgs.writers) makeScriptWriter;
in
{
  writeSBCLScript =
    nameOrPath: argsOrContent:
    if builtins.isAttrs argsOrContent && !lib.attrsets.isDerivation argsOrContent
    then
      let
        sbcl =
          if argsOrContent ? withPackages
          then pkgs.sbcl.withPackages argsOrContent.withPackages
          else pkgs.sbcl;
        
        extraPackages =
          if argsOrContent ? extraPackages
          then
            assert builtins.isList argsOrContent.extraPackages;
            assert builtins.all (e: lib.attrsets.isDerivation e) argsOrContent.extraPackages;
            argsOrContent.extraPackages
          else
            [ ];
        makeWrapperArgs =
          if builtins.length extraPackages > 0
          then
            [
              "--prefix" "PATH" ":" "${lib.strings.makeBinPath extraPackages}"
            ]
          else
            [ ];
      in
        content:
        makeScriptWriter {
          interpreter = "${sbcl}/bin/sbcl --script";
          inherit makeWrapperArgs;
        } nameOrPath (lib.strings.concatLines [
          ''(require "asdf")''
          ''(require "uiop")''
          content
        ])
    else
      makeScriptWriter { interpreter = "${pkgs.sbcl}/bin/sbcl --script"; } nameOrPath
        (lib.strings.concatLines [
          ''(require "uiop")''
          argsOrContent
        ]);
}
