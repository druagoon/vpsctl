---
applyTo: "src/**/*.sh"
description: "Use when editing vpsctl shell sources under src/. Preserve argc metadata, maintain shinc include wiring, reuse std helpers, and validate with the repo's shell build/format steps."
---

# vpsctl Shell Source Instructions

- Treat `src/` as the editable source of truth. Do not move changes into `target/`.
- Preserve existing `argc` metadata comments such as `# @cmd`, `# @flag`, `# @meta`, and `# @describe`; keep them adjacent to the command or hook they define.
- If you add or remove a command or shared library module, update `src/main.sh` `# @include` lines in the same change.
- Prefer existing `std::...` functions from `src/lib/std/` before introducing new generic helpers.
- Keep functions small, use explicit error handling, and follow the repo's 4-space shell formatting style.
- Treat system-mutating operations such as `systemctl`, `nft`, `crontab`, package installation, and account management as high-risk; avoid executing them during validation unless the task explicitly requires it.
- After shell source edits, run `make fmt` for formatting and `shinc build` to confirm the bundled output still regenerates.

See [AGENTS.md](../../AGENTS.md) for repo-wide guidance, architecture details, and directory context.
