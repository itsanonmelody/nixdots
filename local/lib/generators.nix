{ nixpkgs, ... }:
let
  pkgs = nixpkgs.legacyPackages.x86_64-linux;
  lib = pkgs.lib;
in
{
  toHyprlang =
    let
      mkHyprlangValue =
        let
          err = type: value:
            abort ("generators.toHyprlang.mkHyprlangValue: "
                   + "${type} not supported: "
                   + "${lib.generators.toPretty {} value}");
        in
          value:
          if builtins.isInt value then builtins.toString value
          else if lib.attrsets.isDerivation value then builtins.toString value
          else if builtins.isString value then value
          else if true == value then "true"
          else if false == value then "false"
          else if null == value then ""
          else if builtins.isList value then err "lists" value
          else if builtins.isAttrs value then err "attrsets" value
          else if builtins.isFunction value then err "functions" value
          else if builtins.isFloat value then lib.strings.floatToString value
          else err "value" value;
      mkHyprlangLine = name: value: name + " = " + (mkHyprlangValue value);
      mkHyprlangCategory =
        name: attrs:
        assert builtins.isAttrs attrs;
        if attrs == { } then abort ("generators.toHyprlang.mkHyprlangCategory: "
                                    + "empty attrset not supported")
        else if builtins.length (builtins.attrNames attrs) == 1 then
          let
            attrName = (builtins.elemAt (builtins.attrNames attrs) 0);
          in
            mkHyprlangOption
              (name + ":" + attrName)
              attrs.${attrName}
        else
          let
            indent = "    ";
          in
          name + " {\n" +
          (lib.strings.concatLines
            (builtins.map
              (name: indent +
                     (builtins.replaceStrings ["\n"] ["\n${indent}"]
                       (mkHyprlangOption name attrs.${name})))
              (builtins.attrNames attrs)))
          + "}";
      mkHyprlangOption =
        name: value:
        if builtins.isAttrs value then mkHyprlangCategory name value
        else if builtins.isList value then
          lib.strings.concatStringsSep "\n"
            (builtins.map (value: mkHyprlangOption name value) value)
        else mkHyprlangLine name value;
    in
      value:
      if builtins.isAttrs value then
        lib.strings.concatLines
          (builtins.map
            (name: mkHyprlangOption name value.${name})
            (builtins.attrNames value))
      else if builtins.isList value then
        lib.strings.concatLines
          (builtins.map
            (attrs:
              (builtins.map
                (name: mkHyprlangOption name attrs.${name})
                (builtins.attrNames attrs)))
            value)
      else abort "generators.toHyprlang: value not supported: ${value}";
}
