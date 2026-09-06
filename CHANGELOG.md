# Changelog

Notable changes to this template. Entries are named after the Vault version they ship,
and the format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

Before applying an update to a deployment that uses a volume, read [Upgrading](README.md#️-upgrading).

## Infrastructure as Code — 2026-09-06

### Added

- `.railway/railway.ts`, an Infrastructure as Code definition of the project. See
  [Infrastructure as Code](README.md#-infrastructure-as-code).
- CI: `docker-build` builds the image and boots it both ways, `iac-typecheck`
  typechecks `railway.ts`.
- The storage volume is declared with the service, so an apply cannot start a
  file-backed Vault with nowhere to persist.

## Vault 2.1 — 2026-09-06

### Changed

- Upgraded from Vault 1.21 to 2.1. The major version bump reflects HashiCorp moving Vault
  to the IBM versioning and support lifecycle, not an architectural change.
- Vault now runs as the unprivileged `vault` user. Official Vault 2.x images end with
  `USER vault`, while Railway mounts volumes as root, so the entrypoint starts as root,
  takes ownership of `STORAGE_PATH`, then drops privileges with `su-exec`. Volumes written
  by the 1.x version of this template are migrated automatically on first boot — no
  variable changes are needed.

### Upgrade notes

- **There is no downgrade.** Vault may change on-disk data structures during an upgrade,
  so reverting to a 1.x image is not supported. Back up the volume first.
- Vault is sealed after the redeploy, as after any restart. Your existing unseal keys are
  unchanged by the upgrade.
- On `ENV=dev` there is nothing to do — that mode is in-memory and loses data on every
  redeploy regardless.

### Breaking changes in Vault 2.0 that may affect API clients

- `sys/rekey`, `sys/generate-root` and `sys/replication/dr/secondary/generate-operation-token`
  now require a Vault token in addition to the key shares. Set `enable_unauthenticated_access`
  in the config to opt out.
- Request paths must be canonical. Vault rejects anything containing `/../`, `/./` or `//`.

See HashiCorp's [important changes](https://developer.hashicorp.com/vault/docs/updates/important-changes)
for the full list.

## Vault 1.21 — 2026-04-05

### Added

- `PORT` environment variable support.
- `.dockerignore` to keep the build context small.

### Changed

- Upgraded to Vault 1.21.

### Fixed

- Set `api_addr` in the config to silence a startup warning.
