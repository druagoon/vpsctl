<!-- markdownlint-disable MD033 MD036 -->
<h1>vpsctl</h1>

Set up a VPS with basic security and configuration.

**Table of Contents**

- [Development](#development)
  - [Release](#release)

## Development

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
