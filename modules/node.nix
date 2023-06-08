{ config, pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    nodejs_20
    nodePackages.typescript
    yarn
    nodePackages.pm2
  ];
}
