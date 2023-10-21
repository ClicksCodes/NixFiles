{ nixpkgs-clicksforms, system, config, lib, ... }:
let pkgsOld = nixpkgs-clicksforms.legacyPackages.${system};
in {
  home.packages = [
    (pkgsOld.python3.withPackages (pyPkgs:
      with pyPkgs; [
        databases
        sqlalchemy
        orm
        typesystem
        (pyPkgs.callPackage ./discordpy.nix { })
        aiohttp
        fastapi
        aiosqlite
        uvicorn
        validators
        (pyPkgs.fetchPypi {
          pname = "jishaku";
          version = "2.5.1";
          hash = lib.fakeSha256;
        })
        slowapi
      ]))
  ];
}
