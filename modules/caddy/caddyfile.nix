let
  HTTPReverseProxyRoute = hosts: upstreams: {
    handle = [
      {
        handler = "subroute";
        routes = [
          {
            handle = [
              {
                handler = "reverse_proxy";
                upstreams = map (upstream: { dial = upstream; }) upstreams;
              }
            ];
          }
        ];
      }
    ];
    match = [{ host = hosts; }];
    terminal = true;
  };
  HTTPRedirectRoute = hosts: goto: {
    handle = [
      {
        handler = "subroute";
        routes = [
          {
            handle = [
              {
                handler = "static_response";
                headers = { Location = [ goto ]; };
                status_code = 302;
              }
            ];
          }
        ];
      }
    ];
    match = [{ host = hosts; }];
    terminal = true;
  };
  HTTPFileServerRoute = hosts: root: {
    handle = [
      {
        handler = "subroute";
        routes = [
          {
            handle = [
              {
                handler = "file_server";
                inherit root;
              }
            ];
          }
        ];
      }
    ];
    match = [{ host = hosts; }];
    terminal = true;
  };

  TCPReverseProxyRoute = ports: upstreams: {
    listen = map (port: "0.0.0.0:${toString port}") ports;
    routes = [
      {
        handle = [
          {
            handler = "proxy";
            proxy_protocol = "v2";
            upstreams = [{ dial = upstreams; }];
          }
        ];
      }
    ];
  };
in
{ pkgs, lib }: {
  apps = {
    http = {
      servers = {
        srv0 = {
          listen = [ ":443" ];
          routes = [
            (HTTPReverseProxyRoute [ "signup.hopescaramels.com" ] [ "192.168.0.4:3035" ])
            (HTTPReverseProxyRoute [ "homebridge.coded.codes" ] [ "localhost:8581" ])
            {
              handle = [
                {
                  handler = "subroute";
                  routes = [
                    {
                      handle = [
                        {
                          error = "You can't access admin routes from outside the server. Please use SSH tunneling, cURL on the host or similar";
                          handler = "error";
                          status_code = "403";
                        }
                      ];
                      match = [{ path = [ "/_dendrite/admin/*" "/_synapse/admin/*" ]; }];
                      terminal = true;
                    }
                    {
                      handle = [
                        {
                          handler = "reverse_proxy";
                          transport = { protocol = "http"; };
                          upstreams = [{ dial = "localhost:4527"; }];
                        }
                      ];
                    }
                  ];
                }
              ];
              match = [{ host = [ "matrix-backend.coded.codes" ]; }];
              terminal = true;
            }
            (HTTPReverseProxyRoute
              [
                "mail.coded.codes"
                "mail.clicks.codes"
                "mail.hopescaramels.com"
              ]
              [ "localhost:1080" ]
            )
            (HTTPReverseProxyRoute [ "logs.clicks.codes" ] [ "localhost:9052" ])
            (HTTPRedirectRoute
              [
                "hopescaramels.com"
                "www.hopescaramels.com"
              ]
              "https://etsy.com/shop/HopesCaramels"
            )
            # (HTTPReverseProxyRoute [ "omv.coded.codes" ] [ "localhost:6773" ])
            # (HTTPReverseProxyRoute [ "jellyfin.coded.codes" ] [ "localhost:8096" ])
            (HTTPReverseProxyRoute [ "codedpc.coded.codes" ] [ "192.168.0.2:3389" ])
            (HTTPReverseProxyRoute [ "testing.coded.codes" ] [ "192.168.0.2:3030" ])
            (HTTPReverseProxyRoute [ "kavita.clicks.codes" ] [ "localhost:5000" ])
            {
              handle = [
                {
                  handler = "subroute";
                  routes = [
                    {
                      handle = [
                        {
                          handler = "subroute";
                          routes = [
                            {
                              handle = [
                                {
                                  handler = "rewrite";
                                  strip_path_prefix = "/nucleus";
                                }
                              ];
                            }
                            {
                              handle = [
                                {
                                  handler = "reverse_proxy";
                                  upstreams = [{ dial = "127.0.0.1:10000"; }];
                                }
                              ];
                            }
                          ];
                        }
                      ];
                      match = [{ path = [ "/nucleus/*" ]; }];
                    }
                    {
                      handle = [
                        {
                          handler = "error";
                          error = "This API route does not exist";
                          status_code = 404;
                        }
                      ];
                    }
                  ];
                }
              ];
              match = [{ host = [ "api.clicks.codes" ]; }];
              terminal = true;
            }
            {
              handle = [
                {
                  handler = "subroute";
                  routes = [
                    {
                      handle = [
                        {
                          handler = "subroute";
                          routes = [
                            {
                              handle = [
                                {
                                  handler = "rewrite";
                                  strip_path_prefix = "/nucleus";
                                }
                              ];
                            }
                            {
                              handle = [
                                {
                                  handler = "reverse_proxy";
                                  upstreams = [{ dial = "192.168.0.2:10000"; }];
                                }
                              ];
                            }
                          ];
                        }
                      ];
                      match = [{ path = [ "/nucleus/*" ]; }];
                    }
                    {
                      handle = [
                        {
                          handler = "error";
                          error = "This API route does not exist";
                          status_code = 404;
                        }
                      ];
                    }
                  ];
                }
              ];
              match = [{ host = [ "api.coded.codes" ]; }];
              terminal = true;
            }
            (HTTPRedirectRoute
              [
                "www.clicks.codes"
              ]
              "https://clicks.codes{http.request.uri}"
            )
            (HTTPReverseProxyRoute [ "clicks.codes" ] [ "127.0.0.1:3000" ])
            {
              handle = [
                {
                  handler = "subroute";
                  routes = [
                    {
                      handle = [
                        {
                          handler = "static_response";
                          status_code = 200;
                          body = builtins.readFile ./coded.codes/.well-known/matrix;
                          headers = { Access-Control-Allow-Origin = [ "*" ]; };
                        }
                      ];
                      match = [{
                        path = [
                          "/.well-known/matrix/server"
                          "/.well-known/matrix/client"
                        ];
                      }];
                      terminal = true;
                    }
                    {
                      handle = [
                        {
                          handler = "static_response";
                          headers = { Location = [ "https://clicks.codes{http.request.uri}" ]; };
                          status_code = 302;
                        }
                      ];
                    }
                  ];
                }
              ];
              match = [{ host = [ "coded.codes" ]; }];
              terminal = true;
            }
            (HTTPFileServerRoute [ "matrix.coded.codes" ] (
              pkgs.element-web.override {
                conf = {
                  default_server_config = lib.pipe ./coded.codes/.well-known/matrix [
                    builtins.readFile
                    builtins.fromJSON
                  ];
                };
              }
            ))
          ];
        };
        srv1 = {
          listen = [ ":80" ];
          routes = [
            (HTTPReverseProxyRoute
              [
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
              ]
              [ "localhost:1080" ]
            )
          ];
        };
      };
    };
    layer4 = {
      servers = {
        imap-143 = (TCPReverseProxyRoute [ 143 ] [ "localhost:1143" ]);
        imap-993 = (TCPReverseProxyRoute [ 993 ] [ "localhost:1993" ]);
        pop-110 = (TCPReverseProxyRoute [ 110 ] [ "localhost:1110" ]);
        pop-995 = (TCPReverseProxyRoute [ 995 ] [ "localhost:1995" ]);
        smtp-25 = (TCPReverseProxyRoute [ 25 ] [ "localhost:1025" ]);
        smtp-465 = (TCPReverseProxyRoute [ 465 ] [ "localhost:1465" ]);
        smtp-587 = (TCPReverseProxyRoute [ 587 ] [ "localhost:1587" ]);
      };
    };
  };
}
