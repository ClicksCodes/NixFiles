{ config, pkgs, ... }: {
  environment.systemPackages = [ pkgs.mongosh pkgs.mongodb-tools ];
  services.mongodb.enable = true;
  services.mongodb.enableAuth = true;
  services.mongodb.bind_ip = "0.0.0.0";
  services.mongodb.initialRootPassword = "changeme";
  services.mongodb.package = pkgs.mongodb-6_0;
}
