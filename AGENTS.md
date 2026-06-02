# AGENTS.md

## Project Overview

- `vpsctl` is a modular Bash CLI for VPS setup and hardening.
- The CLI is defined with `argc` annotations and bundled with `shinc`.
- Edit source files under `src/`; build artifacts under `target/` are generated.
- The project automates common VPS setup tasks such as firewall configuration, user management, SSH hardening, and service setup like Certbot and Fail2ban.

## Key Technologies

- `Bash` is the primary implementation language.
- [`argc`](https://github.com/sigoden/argc) provides CLI argument parsing and help generation.
- [`shinc`](https://github.com/druagoon/shinc-rs) bundles `@include`-based sources into the final executable.
- `git-cliff` is used for changelog generation.

## Source Of Truth

- Entry point: `src/main.sh`
- Command implementations: `src/commands/*.sh`
- Shared shell helpers: `src/lib/std/*.sh`
- Project-specific helpers: `src/lib/local/utils.sh`
- Build metadata: `.config/shinc/config.toml`

Never hand-edit `target/build/vpsctl.sh` or `target/bin/vpsctl`. Regenerate them from `src/`.

## Directory Structure

- `src/` contains the main source tree.
- `src/hooks.sh` defines `argc` hooks such as `_argc_before`.
- `.config/shinc/config.toml` contains `shinc` build metadata.
- `Argcfile.sh` contains project development tasks.
- `install.sh` is the user-facing installer.
- `target/` contains generated build artifacts and should be treated as derived output.

## Development Workflow

- Run `shinc build` after changing files under `src/` so generated output stays in sync.
- Run `make fmt` to format shell sources in `src/`.
- Run `make fmt-all` when changes also affect TOML formatting.
- There is no dedicated automated test suite in this repo; validate with the narrowest relevant command or build step for the changed area.

## Building And Running

- During development, source files may rely on `shinc` include wiring, so bundling can be required for realistic execution.
- `shinc build` is the primary build path for generating the bundled CLI.

## Release

- Preferred release flow: `shinc release <version>`.
- That release flow updates `.config/shinc/config.toml`, refreshes `CHANGELOG.md` with `git-cliff`, creates the release commit and tag, pushes to the remote, and triggers `.github/workflows/release.yml`.

## Editing Conventions

- Preserve `argc` comment metadata such as `# @cmd`, `# @flag`, and `# @meta` next to the command they describe.
- Preserve `# @include` structure in `src/main.sh`; new command or library modules must be wired there.
- Prefer existing `std::...` helpers from `src/lib/std/` before adding new generic shell helpers.
- Match the existing Bash style: small focused functions, explicit error paths, and 4-space indentation.
- Be careful with commands that operate on live system state (`systemctl`, `nft`, `crontab`, `useradd`, `apt`, `certbot`). Prefer static checks unless the task explicitly requires system changes.
- Prefer modular Bash with small focused scripts and shared helpers from `src/lib/std/`.
- Keep CLI definitions and help metadata in `argc` annotations adjacent to the implementing shell code.
- TOML formatting is handled with `taplo`, available through the project tasks.

## References

- See [README.md](./README.md) for installation, usage, and release flow.
- See [CHANGELOG.md](./CHANGELOG.md) for recent behavioral changes.
