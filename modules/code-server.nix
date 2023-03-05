{ pkgs, ... }: {
  services.code-server = {
    enable = true;
    host = "0.0.0.0";
    auth = "none";
    package = (pkgs.buildFHSUserEnv {
      name = "code-server";
      targetPkgs = pkgs: [ pkgs.code-server ];
      runScript = "code-server";
    });
  };
}
