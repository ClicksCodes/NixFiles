{ drive_paths, lib, ... }: {
  fileSystems = lib.mapAttrs' (name: value: {
    name = value.path;
    value.device = "/dev/disk/by-uuid/${value.uuid}";
  }) drive_paths;
}
