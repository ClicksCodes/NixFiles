{ config, pkgs, ... }: {
  environment.systemPackages = with pkgs; [ gh git git-review ];
}
