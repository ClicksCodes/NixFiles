{ pkgs, ... }: {
  environment.systemPackages = [ pkgs.docker-compose ];
  virtualisation.docker.enable = true;
  users.users.mailu.extraGroups = [ "docker" ];
  users.users.kavita.extraGroups = [ "docker" ];
}
