# Clicks' NixFiles

## Deploying

To deploy these files to our server we use
[deploy-rs](https://github.com/serokell/deploy-rs). If you've got a
flakes-enabled nix installed on your system you can run

```sh
nix run github:serokell/deploy-rs
```

You can also install deploy-rs to your profile, at which point you'll be able to
run

```sh
deploy
```
