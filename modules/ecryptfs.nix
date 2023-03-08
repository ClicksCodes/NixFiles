{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    ecryptfs
    keyutils
  ];
}
