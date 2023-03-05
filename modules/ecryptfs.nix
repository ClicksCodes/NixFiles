{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    ecryptfs
    ecryptfs-helper
  ];
}
