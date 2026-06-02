---
name: release-workflow
description: "Use when preparing, reviewing, or executing a vpsctl release. Covers version checks, changelog validation, shinc release flow, and the GitHub tag-triggered release workflow."
---

# vpsctl Release Workflow

Use this skill for release preparation, release review, or an explicitly requested release execution.

## When To Use

- Preparing the next release version.
- Verifying that version, changelog, and workflow configuration are aligned.
- Reviewing whether a release can be cut safely.
- Executing the repo's release command after the user explicitly asks for it.

## Repository Facts

- The canonical project version lives in `.config/shinc/config.toml`.
- Release notes are generated into `CHANGELOG.md` using `cliff.toml`.
- The supported release command is `shinc release <version>`.
- GitHub Actions publishes release artifacts from `.github/workflows/release.yml` when a tag matching `v<major>.<minor>.<patch>` is pushed.

## Default Workflow

1. Read `.config/shinc/config.toml`, `CHANGELOG.md`, `README.md`, `cliff.toml`, and `.github/workflows/release.yml`.
2. Check whether the worktree is clean before proposing or executing a release.
3. If release-related files changed, validate the narrowest local checks first, especially `shinc build`.
4. Confirm the requested version format is semantic and matches the tag format expected by the workflow.
5. Summarize what `shinc release <version>` will do before running it.

## Execution Rules

- Do not run `shinc release <version>` unless the user explicitly asks to perform the release.
- Treat `shinc release <version>` as a high-impact command because it updates files, creates a commit, creates a tag, and pushes to the remote.
- If the user only asks for review or preparation, stop after reporting readiness, blockers, and the exact command to run.
- Do not hand-edit generated release assets under `target/`; regenerate them through the existing `shinc` workflow.

## Review Checklist

- The next version is updated through the release flow, not by ad hoc edits.
- `CHANGELOG.md` content will be generated from conventional commits according to `cliff.toml`.
- The release workflow still installs `shinc` and `shfmt`, then runs `shinc build`, `shinc man`, `shinc completions`, and `shinc dist`.
- The GitHub workflow trigger still matches tags in the `vX.Y.Z` format.
- Any local validation results are included in the final response.

## Response Pattern

- For review requests: report readiness, blockers, and the exact files or commands that need attention.
- For execution requests: restate the target version, summarize side effects, run the required checks, then execute `shinc release <version>`.
- Always link users to the source documents instead of duplicating their contents.

## References

- [README.md](../../../README.md)
- [.config/shinc/config.toml](../../../.config/shinc/config.toml)
- [cliff.toml](../../../cliff.toml)
- [.github/workflows/release.yml](../../../.github/workflows/release.yml)
