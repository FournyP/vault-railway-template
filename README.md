# Hashicorp Vault example

This example deploys a server of [Hashicorp Vault](https://www.hashicorp.com/products/vault).

[![Deploy on Railway](https://railway.app/button.svg)](https://railway.app/new/template/hashicorp-vault)

## ✨ Features

- Hashicorp Vault

## 💁‍♀️ How to use

- Click the Railway button 👆
- Fill in the variables
- Deploy! 🚄

## ⚠️ Development mode

Running in development mode (`ENV=dev`) uses in-memory storage. **Redeploying or upgrading the Vault version will erase all data.**

To avoid data loss, use [medusa](https://github.com/jonasvinther/medusa) to export your secrets before upgrading and re-import them afterward.

## ⬆️ Upgrading to Vault 2.x

Railway template updates are opt-in — an existing deployment keeps running until you apply the update.

If you use a volume (any `ENV` other than `dev`), before applying it:

- **Back up your data** with Railway volume backups or [medusa](https://github.com/jonasvinther/medusa) — Vault does not support downgrading.
- **Unseal after the redeploy** with your existing keys; the upgrade does not change them.

Volume ownership is migrated automatically on first boot (Vault 2.x runs as a non-root user, Railway mounts volumes as root), so no variable changes are needed. Two 2.0 changes can affect API clients: `sys/rekey` and `sys/generate-root` now also require a token, and non-canonical paths (`/../`, `/./`, `//`) are rejected — see the [important changes](https://developer.hashicorp.com/vault/docs/updates/important-changes).

## 🔐 Security note: `disable_mlock` is enabled

This template sets `disable_mlock: true` in the Vault config. Here is what that means and why:

- Vault normally calls [`mlock(2)`](https://man7.org/linux/man-pages/man2/mlock.2.html) to pin its process memory in RAM, preventing the kernel from paging memory containing secrets (encryption keys, tokens, secret values) to swap on disk.
- `mlock` requires the Linux `IPC_LOCK` capability. Railway does **not** currently expose a way to grant additional Linux capabilities to a container (the `capabilities` field is not part of the [Railway config schema](https://backboard.railway.app/railway.schema.json)), so Vault cannot acquire `IPC_LOCK` and `mlock` would fail.
- Disabling `mlock` is the official Vault workaround when the capability is unavailable. See [HashiCorp's guidance](https://developer.hashicorp.com/vault/docs/configuration#disable_mlock).
- Official Vault 2.x images additionally run Vault as a non-root `vault` user, which cannot acquire capabilities at all. This template keeps that model: the entrypoint is root only long enough to fix volume ownership, then drops to the `vault` user.

### What's the practical impact?

If the underlying host has swap enabled and is under memory pressure, sensitive Vault memory pages **could** be written to a swap file. Recovering keys from swap would require an attacker to obtain disk-level access to the host. On Railway's managed infrastructure end users do not have access to host disks, so the realistic exposure is mainly to Railway's platform itself.

If you need stronger guarantees (regulated workloads, high-value secrets), do not run this template on Railway as-is — deploy Vault on infrastructure where you can grant `IPC_LOCK` (Kubernetes with `securityContext.capabilities`, plain Docker with `--cap-add IPC_LOCK`, or a host with swap disabled).

## 📝 Notes

- Source repo: https://github.com/FournyP/vault-railway-template
- Docs: https://developer.hashicorp.com/vault/docs

## ⚖️ License

[MIT](LICENSE)
