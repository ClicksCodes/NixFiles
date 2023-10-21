{ config, ... }: {
  security = {
    doas = {
      enable = true;
      wheelNeedsPassword = false;
    };
    sudo.enable = false;
  };

  environment.shellAliases.sudo =
    "${config.security.wrapperDir}/${config.security.wrappers.doas.program}";
}
