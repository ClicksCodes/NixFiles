# Home manager is used separately from this deploy, but we still need to create
# user accounts in the system config
{ pkgs, lib, ... }:
let
  mkUser = username: {
    isSystemUser = true;
    linger = true;
    createHome = true;
    home = "/services/${username}";
    group = "clicks";
    shell = pkgs.bashInteractive;
  };
in
{
  imports = [
    (builtins.fetchurl {
      url = "https://gist.githubusercontent.com/graham33/fdbdcc18317a621d9dd54beb36be6683/raw/776ed252749313470f1c9a286a0419ba9746d133/loginctl-linger.nix";
      sha256 = "sha256:0hwm4f13dwd27gbdn5ddvbrmcvfb70jr658jz4nbkzwzh8c02qj8";
    })
  ];

  users.users = lib.pipe ../services [
    builtins.readDir
    (lib.filterAttrs (_name: value: value == "directory"))
    builtins.attrNames
    (map (name: { inherit name; value = mkUser name; }))
    builtins.listToAttrs
  ];
}
