{ pkgs, helpers, config, lib, ... }: {
  clicks.nginx.services = with helpers.nginx; [
    (Host "signup.hopescaramels.com" (ReverseProxy "caramels:1024"))
    (Host "freeflowtaekwondo.com" (ReverseProxy "generic:1026"))
    (Host "homebridge.coded.codes" (ReverseProxy "CodedPi.local:8581"))
    (Host "codedpc.coded.codes" (ReverseProxy "SamuelDesktop.local:3389"))
    (Host "testing.coded.codes" (ReverseProxy "SamuelDesktop.local:3000"))
    (Hosts [ "kavita.coded.codes" "reading.coded.codes" ]
      (ReverseProxy "127.0.0.1:5000"))
    (Host "www.clicks.codes"
      (RedirectPermanent "https://clicks.codes$request_uri"))
    (Host "clicks.codes" (ReverseProxy "127.0.0.1:3000"))
    (Host "passwords.clicks.codes" (ReverseProxy "127.0.0.1:8452"))
    (Host "login.clicks.codes" (ReverseProxy "127.0.0.1:9083"))
    (Hosts [
      "syncthing.clicks.codes"
      "syncthing.coded.codes"
      "syncthing.thecoded.prof"
      "syncthing.hopescaramels.com"
    ] (ReverseProxy "127.0.0.1:8384"))
    (Hosts [ "gerrit.clicks.codes" "git.clicks.codes" ]
      (ReverseProxy "127.0.0.255:1000"))
    (Hosts [ "grafana.clicks.codes" "logs.clicks.codes" ]
      (ReverseProxy "127.0.0.1:9052"))
    (InsecureHosts [
      "mail.clicks.codes"
      "mail.coded.codes"
      "mail.hopescaramels.com"
      "autoconfig.coded.codes"
      "autoconfig.clicks.codes"
      "autoconfig.hopescaramels.com"
      "imap.coded.codes"
      "imap.clicks.codes"
      "imap.hopescaramels.com"
      "pop.coded.codes"
      "pop.clicks.codes"
      "pop.hopescaramels.com"
      "smtp.coded.codes"
      "smtp.clicks.codes"
      "smtp.hopescaramels.com"
    ] (ReverseProxy "127.0.0.1:1080"))
    (Host "matrix.coded.codes" (Directory "${builtins.toString
      (pkgs.schildichat-web.override {
        conf = {
          default_server_config =
            lib.pipe ./nginx/coded.codes/.well-known/matrix [
              builtins.readFile
              builtins.fromJSON
            ];
          features = {
            feature_report_to_moderators = true;
            feature_latex_maths = true;
            feature_pinning = true;
            feature_mjolnir = true;
            feature_presence_in_room_list = true;
            feature_custom_themes = true;
            feature_dehydration = true;
          };
          setting_defaults = { "fallbackICEServerAllowed" = true; };
          default_theme = "dark";
          permalink_prefix = "https://matrix.coded.codes";
          disable_guests = true;
          disable_3pid_login = true;
        };
      })}"))
    (Host "api.clicks.codes"
      (Path "/nucleus/" (ReverseProxy "127.0.0.1:10000")))
    (Host "api.coded.codes"
      (Path "/nucleus/" (ReverseProxy "SamuelDesktop.local:10000")))
    (Host "coded.codes" (Compose [
      (Path "/.well-known/matrix/"
        (File ./nginx/coded.codes/.well-known/matrix))
      (Redirect "https://clicks.codes$request_uri")
    ]))
    (Host "matrix-backend.coded.codes" (Compose [
      (Path "/_synapse/admin/" (Status 403))
      (ReverseProxy "127.0.0.1:4527")
    ]))
  ];
  clicks.nginx.serviceAliases = with helpers.nginx; [
    (Aliases "nextcloud.clicks.codes" [
      "cloud.clicks.codes"
      "docs.clicks.codes"
    ])
    (Aliases "privatebin" [
      "paste.clicks.codes"
      "paste.coded.codes"
      "paste.thecoded.prof"
      "paste.hopescaramels.com"
    ])
  ];
  clicks.nginx.streams = with helpers.nginx; [
    (ProxyStream 143 "127.0.0.1:1143" "tcp") # imap
    (ProxyStream 993 "127.0.0.1:1993" "tcp") # imap
    (ProxyStream 110 "127.0.0.1:1110" "tcp") # pop3
    (ProxyStream 995 "127.0.0.1:1995" "tcp") # pop3
    (ProxyStream 25 "127.0.0.1:1025" "tcp") # smtp
    (ProxyStream 465 "127.0.0.1:1465" "tcp") # smtp
    (ProxyStream 587 "127.0.0.1:1587" "tcp") # smtp
  ];
}
