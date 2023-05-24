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

## Updating secrets

Secrets are stored in SOPS and deployed using scalpel.

If you have a service which needs to store secrets in its config file, please
set systemd reloadTriggers and restartTriggers to automatically reload/restart
the service whenever the configuration changes.

It's notable that changing the secrets _will not_ trigger a reload/restart of
the service. If you want to update the secrets without updating the rest of the
configuration you currently need to manually restart the service. It's possible
that this could be solved by using systemd paths to watch the files (see
<https://superuser.com/questions/1171751/restart-systemd-service-automatically-whenever-a-directory-changes-any-file-ins>)
but this is not a priority
