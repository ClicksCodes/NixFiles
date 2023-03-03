{ config, pkgs, ... }: {
  services.mongodb.enable = true;
  services.mongodb.enableAuth = true;
  services.mongodb.initialRootPassword = "fYhw&%6frpcL9zcJ5p^b^tquP0kyVE9hehoLY4lY2zUUzbIjEyDPhAIMe2M";
  services.mongodb.package = pkgs.mongodb-6_0;
}
