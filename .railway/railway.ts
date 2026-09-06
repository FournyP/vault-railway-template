// Railway Infrastructure as Code: railway config plan | apply
//
// An apply deletes every resource this file does not declare, so link it to a
// project dedicated to this template.
//
// On ENV=dev only, export the root token for the first apply; later runs omit
// it and preserve() keeps Railway's.
//
//   export DEV_ROOT_TOKEN_ID=$(openssl rand -hex 16)
//
// Read CHANGELOG.md before applying an update to a deployment with a volume.

import { defineRailway, github, preserve, project, service, volume } from "railway/iac";

const REPO = "FournyP/vault-railway-template";

// Matched by name, so keep these identical to Railway: a mismatch is a
// delete and recreate, not a rename.
const VAULT_SERVICE = "vault";
const DATA_VOLUME = "vault-data";

// Vault's file backend owns this directory. Railway mounts volumes as root and
// Vault 2.x runs unprivileged, so the entrypoint chowns it before dropping.
const STORAGE_PATH = "/vault/file";

/** Push the value from the local environment if present, else keep Railway's. */
const fromEnvOrPreserve = (name: string) => process.env[name] ?? preserve();

export default defineRailway(() => {
  const data = volume(DATA_VOLUME, { sizeMB: 1024 });

  const vault = service(VAULT_SERVICE, {
    source: github(REPO, { branch: "main" }),
    build: { builder: "DOCKERFILE", dockerfilePath: "Dockerfile" },
    volumeMounts: {
      [STORAGE_PATH]: data,
    },
    deploy: {
      // The file backend is single-writer; a second replica corrupts it.
      numReplicas: 1,
    },
    env: {
      // Anything but "dev" uses the file backend. "dev" is in-memory and loses
      // every secret on each redeploy.
      ENV: "file",

      // Listener port, baked into config.json at build time. Declared so an
      // apply cannot delete it and silently move the listener.
      PORT: "8200",

      // STORAGE_PATH is read at build time by config.sh and again at runtime by
      // the entrypoint. The three below are build-time only: Railway passes
      // service variables as build args because the Dockerfile declares
      // matching ARGs, so changing them needs a rebuild, not just a restart.
      STORAGE_PATH,
      DEFAULT_LEASE_TTL: "168h",
      MAX_LEASE_TTL: "720h",
      UI_ENABLED: "true",

      // Dev mode only. Ignored when ENV is anything else.
      DEV_ROOT_TOKEN_ID: fromEnvOrPreserve("DEV_ROOT_TOKEN_ID"),
    },
  });

  return project("Vault", { resources: [data, vault] });
});
