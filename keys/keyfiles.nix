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
      (potentialKey: (
        isString potentialKey
        && potentialKey != ""
        # cannot start as a comment
        && (substring 0 1 potentialKey) != "#"
      ))
      (split "\n" value);
  };
  keys = mapAttrs' splitAndClean keysContents;
in
keys
