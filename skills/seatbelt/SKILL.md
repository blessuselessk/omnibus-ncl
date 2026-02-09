---
name: seatbelt
description: Use when configuring macOS sandbox execution with Seatbelt profiles, generating sandbox-exec profiles, or testing macOS sandbox restrictions.
metadata:
  author: omni-dev-fusion
  version: "1.1.0"
  source: "https://github.com/tao3k/omni-dev-fusion/tree/main/packages/ncl/sandbox/seatbelt"
  routing_keywords:
    - "seatbelt"
    - "sandbox-exec"
    - "macos"
    - "sandbox"
    - "apple"
    - "darwin"
    - "sbpl"
    - "entitlements"
    - "mac"
---

# Seatbelt Skill

macOS sandbox configuration using Seatbelt (sandbox-exec).

## Commands

| Command | Description |
|---------|-------------|
| [`seatbelt_profile`](#seatbelt_profile) | Generate Seatbelt profile |
| [`seatbelt_export`](#seatbelt_export) | Export SBPL profile to file |

## Quick Usage

```bash
# Generate profile with override
nickel export examples/python-script-runner.ncl --field _profile -f text -- \
  --override 'home_dir="/Users/guangtao"' \
  --override 'script_path="/path/to/script.py"' \
  > /tmp/profile.sb

# Run in sandbox
sandbox-exec -f /tmp/profile.sb /usr/bin/python3 /path/to/script.py
```

## Nickel CLI

### Basic Export

```bash
# Export as text
nickel export config.ncl -f text

# Export specific field
nickel export --field _profile config.ncl -f text
```

### Customize Mode

```bash
# List available fields
nickel export config.ncl -- list

# Override values
nickel export config.ncl -f text -- \
  --override 'home_dir="/Users/guangtao"' \
  --override 'script_path="/path/to/script.py"'
```

## Concepts

| Topic | Description | Reference |
|-------|-------------|-----------|
| Profile Types | Sandbox profiles | [profiles.md](references/profiles.md) |
| SBPL Syntax | SBPL reference | [sbpl-syntax.md](references/sbpl-syntax.md) |
| Path Matching | Path patterns | [path-matching.md](references/path-matching.md) |

## Python Sandbox Example

```bash
# Generate profile
nickel export examples/python-script-runner.ncl --field _profile -f text -- \
  --override 'home_dir="/Users/guangtao"' \
  --override 'script_path="/Users/guangtao/projects/my_script.py"' \
  --override 'python_path="/usr/bin/python3"' \
  > /tmp/profile.sb

# Run
sandbox-exec -f /tmp/profile.sb /usr/bin/python3 /Users/guangtao/projects/my_script.py
```

## Best Practices

- Use `--override` to customize paths per user
- Use `--field _profile` to export only the profile
- Use `-f text` for sandbox-exec (not JSON)
- Test profiles with `sandbox-exec` before deployment

## Related Skills

| Topic | Description | Reference |
|-------|-------------|-----------|
| Nsjail | Linux sandboxing | [nsjail](../nsjail/SKILL.md) |
