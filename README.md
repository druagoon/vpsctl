<!-- markdownlint-disable MD033 MD036 -->
<h1>vpsctl</h1>

Set up a VPS with basic security and configuration.

**Table of Contents**

- [Usage](#usage)
- [Examples](#examples)
- [Development](#development)
  - [Dependencies](#dependencies)
  - [Release](#release)
- [Changelog](#changelog)

## Usage

- `vpsctl --help` to list all commands.
- `vpsctl [command] --help` to see details.

## Examples

> If you are not running as the root user, you need to add sudo before each command.

```sh
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

- [`shinc`](https://github.com/druagoon/shinc-rs)

### Release

To create a new release:

Run the `shinc release` command with the new version:

```sh
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
