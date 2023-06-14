{ config, pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    nodejs_20
    nodePackages.typescript
    nodePackages.pnpm
    nodePackages.pm2
  ];
}
