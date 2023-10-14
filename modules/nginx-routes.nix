{ pkgs, helpers, config, lib, ... }: {
  clicks.nginx.services = with helpers.nginx; [
    (Host "signup.hopescaramels.com" (ReverseProxy "CodedPi.local:3035"))
    (Host "homebridge.coded.codes" (ReverseProxy "CodedPi.local:8581"))
    (Host "codedpc.coded.codes" (ReverseProxy "SamuelDesktop.local:3389"))
    (Host "testing.coded.codes" (ReverseProxy "SamuelDesktop.local:3000"))
    (Hosts [ "kavita.coded.codes" "reading.coded.codes" ]
      (ReverseProxy "localhost:5000"))
    (Host "www.clicks.codes" (RedirectPermanent "https://clicks.codes$request_uri"))
    (Host "clicks.codes" (ReverseProxy "127.0.0.1:3000"))
    (Host "passwords.clicks.codes" (ReverseProxy "localhost:8452"))
    (Host "login.clicks.codes" (ReverseProxy "localhost:9083"))
    (Hosts [
      "syncthing.clicks.codes"
      "syncthing.coded.codes"
      "syncthing.thecoded.prof"
      "syncthing.hopescaramels.com"
    ] (ReverseProxy "localhost:8384"))
    (Hosts [ "gerrit.clicks.codes" "git.clicks.codes" ]
      (ReverseProxy "127.0.0.255:1000"))
    (Hosts [ "grafana.clicks.codes" "logs.clicks.codes" ]
      (ReverseProxy "localhost:9052"))
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
    ] (ReverseProxy "localhost:1080"))
    (Hosts [
      "mail.clicks.codes"
      "mail.coded.codes"
      "mail.hopescaramels.com"
    ] (ReverseProxy "localhost:1080"))
    (Host "matrix.coded.codes" (Directory "${builtins.toString (pkgs.schildichat-web.override {
      conf = {
        default_server_config = lib.pipe ./nginx/coded.codes/.well-known/matrix [
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
    (Host "api.clicks.codes" (Path "/nucleus/" (ReverseProxy "localhost:10000")))
    (Host "api.coded.codes" (Path "/nucleus/" (ReverseProxy "SamuelDesktop.local:10000")))
    (Host "coded.codes" (Compose [
      (Path "/.well-known/matrix/" (File ./nginx/coded.codes/.well-known/matrix))
      (Redirect "https://clicks.codes$request_uri")
    ]))
    (Host "matrix-backend.coded.codes" (Compose [
      (Path "/_synapse/admin/" (Status 403))
      (ReverseProxy "localhost:4527")
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
    (Stream 143 "localhost:1143" "tcp") #imap
    (Stream 993 "localhost:1993" "tcp") #imap
    (Stream 110 "localhost:1110" "tcp") #pop3
    (Stream 995 "localhost:1995" "tcp") #pop3
    (Stream  25 "localhost:1025" "tcp") #smtp
    (Stream 465 "localhost:1465" "tcp") #smtp
    (Stream 587 "localhost:1587" "tcp") #smtp
  ];
}
