{
  description = "A flake to deploy and configure Clicks' NixOS server";

  inputs.deploy-rs.url = "github:serokell/deploy-rs";

  outputs = { self, nixpkgs, deploy-rs, ... }@inputs: {
    nixosConfigurations.clicks =
      let
        system = "x86_64-linux";
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      in
      nixpkgs.lib.nixosSystem {
        inherit system pkgs;
        modules = [
          ./default/configuration.nix
          ./default/hardware-configuration.nix
          ./modules/mongodb.nix
          ./modules/git.nix
          ./modules/caddy.nix
          ./modules/fuck.nix
          ./modules/node.nix
          {
            security.sudo.wheelNeedsPassword = false;
            users.mutableUsers = false;
          }
        ];
      };

    deploy.nodes.clicks = {
      profiles.system = {
        remoteBuild = true;
        user = "root";
        path = deploy-rs.lib.x86_64-linux.activate.nixos
          self.nixosConfigurations.clicks;
      };
      hostname = "192.168.89.74";
      profilesOrder = [ "system" ];
    };

    formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;
  };
}