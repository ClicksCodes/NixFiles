# Home manager is used separately from this deploy, but we still need to create
# user accounts in the system config
{ base, pkgs, lib, config, ... }:
let
  mkUser = username:
    {
      isSystemUser = true;
      linger = true;
      createHome = true;
      home = "/services/${username}";
      group = "clicks";
      shell = pkgs.bashInteractive;
    } // (if builtins.pathExists "${../services}/${username}/system.nix" then
      import "${../services}/${username}/system.nix"
    else
      { });
in {
  users.users = lib.pipe ../services [
    builtins.readDir
    (lib.filterAttrs (_name: value: value == "directory"))
    builtins.attrNames
    (map (name: {
      inherit name;
      value = mkUser name;
    }))
    builtins.listToAttrs
  ];
} // (if (base != null) then
  {
    /* users.groups = lib.mapAttrs'
       (_: user: {
         name = user.group;
         value = { };
       })
       base.config.users.users;
    */
  }
else
  { })
