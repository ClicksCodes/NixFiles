{
  description = "A very basic flake";

  outputs = { self, nixpkgs }: {

    packages.x86_64-linux.hello = nixpkgs.legacyPackages.x86_64-linux.hello;

    packages.x86_64-linux.nixosConfigurations.nixos =
      let
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
      in
      nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          {
            nixpkgs.config.allowUnfree = true;
            services.mongodb.enable = true;
            services.mongodb.package = pkgs.mongodb-6_0;
          }
          ./configuration.nix
        ];
      };

  };
}
