{ nixpkgs, ... }:
let
  lib = nixpkgs.lib;
  inherit (lib.asserts) assertMsg;
  inherit (lib.strings)
    concatMapStrings
    floatToString;
  inherit (lib.trivial) min max mod;
  inherit (builtins)
    all
    attrNames
    attrValues
    elemAt
    floor
    foldl'
    getAttr
    isAttrs
    isList
    isString
    length
    toString;
  
  inRange = value: start: end: start <= value && value <= end;
  isValidRgb =
    value: isAttrs value && length (attrNames value) == 3
           && value ? r && inRange value.r 0 255
           && value ? g && inRange value.g 0 255
           && value ? b && inRange value.b 0 255;
  isValidHsv =
    value: isAttrs value && length (attrNames value) == 3
           && value ? h && inRange value.h 0 359
           && value ? s && inRange value.s 0.0 1.0
           && value ? v && inRange value.s 0.0 1.0;

  isColor =
    value: isAttrs value
           && value ? _type
           && value._type == "color";
  assertColor = value: assertMsg (isColor value)
    "provided value is not a valid color!";
in
rec {
  mkColor =
    { rgb ? null,
      hsv ? null,
      alpha ? 1.0, }:
    assert assertMsg (rgb != null && hsv == null
                      || rgb == null && hsv != null)
      "only one of RGB and HSV values can be passed!";
    assert assertMsg (rgb != null -> isValidRgb rgb)
      "incorrect RGB value given!";
    assert assertMsg (hsv != null -> isValidHsv hsv)
      "incorrect HSV value given!";
    let
      colorValue =
        if rgb != null then rgbToHsv rgb
        else hsv;
    in
      {
        _type = "color";
        inherit alpha;
        inherit (colorValue) h s v;
      };
  mkColorRgb = r: g: b: mkColor { rgb = { inherit r g b; }; };
  mkColorHsv = h: s: v: mkColor { hsv = { inherit h s v; }; };
  saturate =
    color: value:
    assert assertColor color;
    let inherit (toHsv color) h s v; in
    mkColor {
      hsv = {
        s = max 0.0 (min 1.0 (s + value));
        inherit h v;
      };
      inherit (color) alpha;
    };
  desaturate = color: value: saturate color (-value);
  strengthen =
    color: value:
    assert assertColor color;
    let inherit (toHsv color) h s v; in
    mkColor {
      hsv = {
        v = max 0.0 (min 1.0 (v + value));
        inherit h s;
      };
      inherit (color) alpha;
    };
  weaken = color: value: strengthen color (-value);
  rgbToHsv =
    rgb:
    let
      inherit (rgb) r g b;
      maxValue = foldl' max 0 (attrValues rgb);
      minValue = foldl' min 255 (attrValues rgb);
      diffValue = maxValue - minValue;

      calcHue =
        start: ref:
        let
          refNoSV = 255 - (255 * (maxValue - ref)) / diffValue;
        in
        start + (60 * refNoSV) / 255;

      h = if maxValue == minValue then 0
          else if r == maxValue then
            if g == b then 0
            else if g > b then calcHue 0 g
            else calcHue 300 (255 - b)
          else if g == maxValue then
            if r == b then 120
            else if b > r then calcHue 120 b
            else calcHue 60 (255 - r)
          else
            if r == g then 240
            else if r > g then calcHue 240 r
            else calcHue 180 (255 - g);
      s = if maxValue == minValue then 0
          else (1.0 * diffValue) / maxValue;
      v = maxValue / 255.0;
    in
      { inherit h s v; };
  hsvToRgb =
    hsv:
    let
      p = floor (255 * hsv.v);
      s =
        let
          r = mod hsv.h 60;
          x = if mod (hsv.h / 60) 2 == 0 then r
              else (60 - r);
          y = (255 * x) / 60.0;
          z = (255 - y) * (1.0 - hsv.s);
        in
          floor ((y + z) * hsv.v);
      t = floor (((1.0 - hsv.s) * 255) * hsv.v);
    in
      if hsv.h < 60 then { r = p; g = s; b = t; }
      else if hsv.h < 120 then { r = s; g = p; b = t; }
      else if hsv.h < 180 then { r = t; g = p; b = s; }
      else if hsv.h < 240 then { r = t; g = s; b = p; }
      else if hsv.h < 300 then { r = s; g = t; b = p; }
      else { r = p; g = t; b = s; };
  toHsv =
    color:
    assert assertColor color;
    { inherit (color) h s v; };
  toRgb = color: hsvToRgb (toHsv color);
  toRgba = color: toRgb color // { a = color.alpha; };
  toHexString =
    format: color:
    assert assertColor color;
    assert assertMsg (isList format && all isString format)
      "invalid format list!";
    let
      hsvInBytes =
        let hsv = toHsv color; in
        {
          h = (255 * hsv.h) / 359;
          s = floor (255 * hsv.s);
          v = floor (255 * hsv.v);
        };
      rgb = toRgb color;
      formatValues = {
        a = floor (255 * color.alpha);
      } // rgb // hsvInBytes;

      toHex =
        v: if v < 16 then "0" + lib.trivial.toHexString v
           else lib.trivial.toHexString v;
    in
      concatMapStrings
        (f: toHex (getAttr f formatValues))
        format;
  toHexStringRgb = toHexString [ "r" "g" "b" ];
  toHexStringRgba = toHexString [ "r" "g" "b" "a" ];
  toRgbString =
    color:
    assert assertColor color;
    let
      rgb = toRgb color;
    in
      "rgb(${toString rgb.r}, ${toString rgb.g}, "
      + "${toString rgb.b})";
  toRgbaString =
    color:
    assert assertColor color;
    let
      rgba = toRgba color;
    in
      "rgba(${toString rgba.r}, ${toString rgba.g}, "
      + "${toString rgba.b}, ${floatToString rgba.a})";
}
