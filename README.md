<!-- markdownlint-disable MD033 MD036 -->
<h1>vpsctl</h1>

Set up a VPS with basic security and configuration.

**Table of Contents**

- [Installation](#installation)
  - [Pre-built Binaries](#pre-built-binaries)
- [Usage](#usage)
- [Examples](#examples)
- [Development](#development)
  - [Dependencies](#dependencies)
  - [Release](#release)
- [Changelog](#changelog)

## Installation

### Pre-built Binaries

Alternatively, download pre-built binaries from [GitHub Releases](https://github.com/druagoon/vpsctl/releases),
then extract it, and add the `vpsctl` binary to your `$PATH`.

You can use the following command to download the latest release.

```shell
curl -fsSL https://github.com/druagoon/vpsctl/raw/master/install.sh | bash -s
```

Or see more help.

```shell
curl -fsSL https://github.com/druagoon/vpsctl/raw/master/install.sh | bash -s -- --help
```

## Usage

- `vpsctl --help` to list all commands.
- `vpsctl <command> --help` to see more help about the command.

## Examples

> If you are not running as the root user, you need to add sudo before each command.

```shell
vpsctl system
vpsctl user --sudo [name]
vpsctl ssh
vpsctl firewall
vpsctl fail2ban --restart
vpsctl certbot --domain=www.example.com
vpsctl gost --domain=www.example.com --web-password=123456 --socks-password=123456
```

## Development

### Dependencies

- [shinc](https://github.com/druagoon/shinc-rs)

### Release

To create a new release:

Run the `shinc release` command with the new version:

```shell
shinc release <version>
```

This will:

- Update version in `.config/shinc/config.toml`
- Update `CHANGELOG.md` using `cliff.toml` configuration by `git-cliff`
- Commit changes
- Create a git tag
- Push to git remote

Then the release workflow will automatically:

- Build the binaries
- Create a GitHub release

## Changelog

See [CHANGELOG.md](./CHANGELOG.md).
