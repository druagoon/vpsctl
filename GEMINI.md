# GEMINI.md - vpsctl Project Context

## Project Overview

`vpsctl` is a modular Bash-based CLI tool designed for quick and secure VPS setup and configuration. It automates common tasks like firewall configuration, user management, SSH hardening, and setting up services like Certbot and Fail2ban.

### Key Technologies

- **Bash**: The primary programming language.
- **[argc](https://github.com/sigoden/argc)**: Used for CLI argument parsing and help message generation.
- **[shinc](https://github.com/druagoon/shinc-rs)**: A shell script bundler and release management tool. It handles the `@include` directives in the source code to produce a single executable.
- **git-cliff**: Used for generating changelogs.

## Directory Structure

- `src/`: Main source directory.
  - `main.sh`: Entry point for the `vpsctl` command. Includes libraries and command modules.
  - `commands/`: Implementation of individual CLI commands (e.g., `firewall.sh`, `ssh.sh`, `user.sh`).
  - `lib/std/`: A "standard library" of reusable Bash functions (array handling, color output, OS detection, etc.).
  - `lib/local/`: Project-specific utility functions.
  - `hooks.sh`: Hooks for `argc` (e.g., `_argc_before`).
- `.config/shinc/config.toml`: Configuration for the `shinc` build tool.
- `Argcfile.sh`: Task runner for project development (e.g., formatting TOML files).
- `install.sh`: Installation script for users.
- `target/`: (Ignored by git) Contains build artifacts.

## Building and Running

### Development

To run the project directly from source during development, you would typically use `argc` or call the scripts if you have the dependencies installed. However, because of the `@include` directives, the script might need bundling to run correctly if it relies on `shinc`'s bundling logic.

### Building

The project uses `shinc` for building. While a direct "build" command isn't explicitly listed in `Argcfile.sh`, `shinc` is mentioned as the primary tool for development and release.

### Release

To create a new release:

```shell
shinc release <version>
```

This command (as described in `README.md`):

1. Updates the version in `.config/shinc/config.toml`.
2. Updates `CHANGELOG.md` using `git-cliff`.
3. Commits changes and creates a git tag.
4. Pushes to the remote repository.
5. Triggers the GitHub Action in `.github/workflows/release.yml` to build and publish binaries.

## Development Conventions

- **Modular Bash**: Code is split into small, focused scripts.
- **Standard Library**: Prefer using functions from `src/lib/std/` for common tasks to ensure consistency.
- **CLI Definition**: Commands and their metadata (descriptions, flags) are defined using `argc` comments (e.g., `# @cmd`, `# @flag`) directly in the shell scripts.
- **Formatting**: TOML files are formatted using `taplo` (can be run via `argc toml:format`).
