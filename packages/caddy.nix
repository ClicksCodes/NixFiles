# https://github.com/NixOS/nixpkgs/issues/14671#issuecomment-1016376290
{ lib, pkgs, fetchFromGitHub, buildGoModule, plugins ? [ ], vendorSha256 ? "" }:

with lib;
with pkgs;

let
  pluginSrc = fetchFromGitHub {
    owner = "mholt";
    repo = "caddy-l4";
    rev = "aa8cf68a3b5197c45a8b4ffd99b74465f0b5a6b1";
    hash = "sha256-3KcoOAB+YkOU8qKM75uQo58/dljRBmP25dionQ9K2dc=";
  };
  caddySrc = srcOnly (fetchFromGitHub {
    owner = "caddyserver";
    repo = "caddy";
    rev = "v2.6.4";
    hash = "sha256-3a3+nFHmGONvL/TyQRqgJtrSDIn0zdGy9YwhZP17mU0=";
  });

  combinedSrc = stdenv.mkDerivation {
    name = "caddy-src";

    nativeBuildInputs = [ go ];

    buildCommand = ''
      export GOCACHE="$TMPDIR/go-cache"
      export GOPATH="$TMPDIR/go"

      mkdir -p "$out/ourcaddy"

      cp -r ${caddySrc} "$out/caddy"
      cp -r ${pluginSrc} "$out/plugin"

      cd "$out/ourcaddy"

      go mod init caddy
      echo "package main" >> main.go
      echo 'import caddycmd "github.com/caddyserver/caddy/v2/cmd"' >> main.go
      echo 'import _ "github.com/mholt/caddy-l4"' >> main.go
      echo "func main(){ caddycmd.Main() }" >> main.go
      go mod edit -require=github.com/caddyserver/caddy/v2@v2.6.4
      go mod edit -replace github.com/caddyserver/caddy/v2=../caddy
      go mod edit -require=github.com/mholt/caddy-l4@v0.0.0
      go mod edit -replace github.com/mholt/caddy-l4=../plugin
    '';
  };
in
buildGoModule {
  name = "meowdy";

  src = combinedSrc;

  vendorHash = "sha256-GmgK2gPCkXXqVcxx+U0h7zJwRGBqFiBA7R0FwHY0SF0=";

  overrideModAttrs = _: {
    postPatch = "cd ourcaddy";

    postConfigure = ''
      go mod tidy
    '';

    postInstall = ''
      mkdir -p "$out/.magic"
      cp go.mod go.sum "$out/.magic"
    '';
  };

  postPatch = "cd ourcaddy";

  postConfigure = ''
    cp vendor/.magic/go.* .
  '';
}
