# https://github.com/NixOS/nixpkgs/issues/14671#issuecomment-1016376290
{ lib, pkgs, fetchFromGitHub, buildGoModule, plugins ? [ ] }:

with lib;
with pkgs;

let
  caddySrc = fetchFromGitHub {
    # github.com/caddyserver/caddy/v2
    owner = "caddyserver";
    repo = "caddy";
    rev = "v2.6.4";
    hash = "sha256-3a3+nFHmGONvL/TyQRqgJtrSDIn0zdGy9YwhZP17mU0=";
  };
  l4Src = fetchFromGitHub {
    # github.com/mholt/caddy-l4
    owner = "mholt";
    repo = "caddy-l4";
    rev = "aa8cf68a3b5197c45a8b4ffd99b74465f0b5a6b1";
    hash = "sha256-3KcoOAB+YkOU8qKM75uQo58/dljRBmP25dionQ9K2dc=";
  };
  cloudflareSrc = fetchFromGitHub {
    # github.com/caddy-dns/cloudflare
    owner = "caddy-dns";
    repo = "cloudflare";
    rev = "a9d3ae2690a1d232bc9f8fc8b15bd4e0a6960eec";
    hash = "sha256-bqnk4XkhUI7YhCv24ha8mds5EaYphnYj8wy/mFOieqI=";
  };

  combinedSrc = stdenv.mkDerivation {
    name = "caddy-src";

    nativeBuildInputs = [ go ];

    buildCommand = ''
      export GOCACHE="$TMPDIR/go-cache"
      export GOPATH="$TMPDIR/go"

      mkdir -p "$out/ourcaddy"

      cp -r ${caddySrc} "$out/caddy"
      cp -r ${l4Src} "$out/l4"
      cp -r ${cloudflareSrc} "$out/cloudflare"

      cd "$out/ourcaddy"

      go mod init caddy
      echo "package main" >> main.go

      echo 'import caddycmd "github.com/caddyserver/caddy/v2/cmd"' >> main.go

      echo 'import _ "github.com/caddyserver/caddy/v2/modules/standard"' >> main.go
      echo 'import _ "github.com/mholt/caddy-l4"' >> main.go
      echo 'import _ "github.com/caddy-dns/cloudflare"' >> main.go

      echo "func main(){ caddycmd.Main() }" >> main.go

      go mod edit -require=github.com/caddyserver/caddy/v2@v2.6.4
      go mod edit -replace github.com/caddyserver/caddy/v2=../caddy
      go mod edit -require=github.com/mholt/caddy-l4@v0.0.0
      go mod edit -replace github.com/mholt/caddy-l4=../l4
      go mod edit -require=github.com/caddy-dns/cloudflare@v0.0.0
      go mod edit -replace github.com/caddy-dns/cloudflare=../cloudflare
    '';
  };
in buildGoModule {
  name = "caddy-with-plugins";

  src = combinedSrc;

  vendorHash = "sha256-34o91x7Y7DjIHom2Tk2ARBcJ3PzBVm+ALWK9ucj1g5A=";

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
