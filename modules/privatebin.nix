{ config, lib, base, ... }:
lib.recursiveUpdate
{
  services.privatebin = {
    enable = true;
    settings = {
      main = {
        name = "Clicks Minute Paste";
        basepath = "https://privatebin.clicks.codes/";
        opendiscussion = true;
        fileupload = true;

        defaultformatter = "syntaxhighlighting";
        syntaxhighlightingtheme = "sons-of-obsidian";
        template = "bootstrap-dark";

        info = ''Powered by <a href="https://privatebin.info/">PrivateBin</a>. Provided as a service free-of-charge by Clicks. Come chat with us <a href="https://matrix.to/#/#global:coded.codes"> on Matrix</a>'';
        notice = "This service has no guarantee of uptime, and pastes are not backed up. If you need somewhere to host the last words of your wise old grandfather for time immemorial this is not the place.";

        langaugeselection = true;
      };

      nginx = {
        serverName = "privatebin.clicks.codes";
        enableACME = true;
      };

      expire.default = "1month";

      expire_options = {
        "5min" = 300; # looks bonkers, but I'm trying to keep the list ordered while also keeping the privatebin label formatter happy
        "10min" = 600;
        "1hour" = 3600;
        "1day" = 86400;
        "1week" = 604800;
        "1month" = 2592000;
      };

      formatter_options = {
        syntaxhighlighting = "Source Code";
        markdown = "Markdown";
        plaintext = "Plain Text";
      };

      traffic = {
        exempted = "10.0.0.0/8,127.0.0.0/8,169.254.0.0/16,172.16.0.0/12,192.168.0.0/16";
      };

      model.class = "Database";
      model_options = {
        dsn = "pgsql:host=localhost;dbname=privatebin";
        tbl = "privatebin";
        usr = "privatebin";
        pwd._env = "PRIVATEBIN_DB_PASSWORD";
      };
    };
  };
}
(
  if base != null
    then {
      services.privatebin.environmentFiles = [
        config.scalpel.trafos."privatebin.env".destination
      ];

      scalpel.trafos."privatebin.env" = {
        source = builtins.toFile "privatebin.env" ''
          PRIVATEBIN_DB_PASSWORD=!!privatebin_db_password!!
        '';
        matchers."privatebin_db_password".secret =
          config.sops.secrets.clicks_privatebin_db_password.path;
        owner = config.users.users.privatebin.name;
        group = config.users.users.privatebin.group;
        mode = "0400";
      };
    }
    else {})
