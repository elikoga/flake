{ lib ? (import <nixpkgs> { }).lib }:
with builtins; with lib; with attrsets;
let
  thisFolder = readDir ./.;
  keysFilter = filterAttrs (fileName: fileType:
    (!isNull (match ".*\.keys" fileName))
    && fileType == "regular");
  keysFiles = attrNames (keysFilter thisFolder);
  keysContents = genAttrs keysFiles (f: readFile (./. + "/${f}"));
  splitAndClean = name: value: {
    name = head (split ".keys" name);
    value = filter
      (potentialKey: !(
        isList potentialKey
        || potentialKey == ""
      ))
      (split "\n" value);
  };
  keys = mapAttrs' splitAndClean keysContents;
in
keys
