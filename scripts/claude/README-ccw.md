# Claude Cloud Worker setup

Provisioning for Claude Code cloud sessions ("Claude Cloud Worker", `ccw`).

| File | Role |
|------|------|
| `cloud-setup.sh` | The real setup. Installs Claude plugins and cloud CLIs. |
| `cloud-setup-stub.sh` | Template for the environment's setup script. Pins a release tag and runs `cloud-setup.sh`. |

## How it runs

- **The setup script works like a Docker image layer.** It runs before Claude starts, and the result is cached as a filesystem snapshot.
- **The cache rebuilds only on change.** Editing the setup script or the network hosts rebuilds it, and so does the cache expiry after about 7 days.
- **Repositories are cloned per session, after the snapshot.** Anything written into a repo checkout here is lost.
- **Saved environment variables are not visible to the setup script.** The stub exports the values `cloud-setup.sh` needs.

## Scope

- **Plugins:** `jpai-essentials` and `jpai-ccw` from the `jpeakai` marketplace.
- **Cloud CLIs:** AWS CLI v2 and the `ccw` AWS profile.
- **Not here: git config.** Per-session state belongs to the `ccw-setup` skill in the `jpai-ccw` plugin, which runs inside the session.

## Releasing

Releases use namespaced tags, `ccw/vMAJOR.MINOR.PATCH`, separate from the rest of this repo.

1. **Merge the change to `main`.**
2. **Tag the merge commit.**
   ```sh
   git tag -a ccw/v1.1.0 -m "ccw: <summary>"
   git push origin ccw/v1.1.0
   ```
3. **Bump `CCW_REF` in the environment's setup script.** The edit rebuilds the cache.

A new plugin release needs no new tag. Edit the cache-bust date in the stub instead, which reinstalls the latest plugins.
