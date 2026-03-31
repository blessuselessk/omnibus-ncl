# Seatbelt Profile Types

Pre-configured sandbox profiles for macOS.

## Quick Usage

```bash
# Generate profile
nickel export examples/seatbelt-standard.ncl --field _profile -f text > profile.sb

# Run
sandbox-exec -f profile.sb /bin/pwd
```

## Profile Comparison

| Profile | Network | FS Access | Use Case |
|---------|---------|-----------|----------|
| `minimal` | deny | ro /tmp | Read-only ops |
| `standard` | localhost | whitelist | Development |
| `development` | full | whitelist | Full access |
| `python` | full | python dirs | Python scripts |

## Python Sandbox Profile

Example: `examples/python-script-runner.ncl`

```bash
# Generate with override
nickel export examples/python-script-runner.ncl --field _profile -f text -- \
  --override 'home_dir="/Users/guangtao"' \
  --override 'script_path="/Users/guangtao/projects/script.py"' \
  > profile.sb

# Run
sandbox-exec -f profile.sb /usr/bin/python3 /Users/guangtao/projects/script.py
```

## Minimal Profile

```nickel
let Sandbox = import "../seatbelt/interface.ncl" in

Sandbox.build {
  id = "minimal",
  backend = 'seatbelt,
  cmd = ["/bin/pwd"],
  network = { enabled = false },
  fs = {
    mode = 'ro,
    allowed_paths = ["/tmp"],
  },
} |> Sandbox.to_profile
```

Output:

```sbpl
(version 1)
(allow default)
(deny network-outbound)
(deny network-inbound)
(allow file-read-data file-write-data (subpath "/tmp"))
```

## Standard Profile

```nickel
let Sandbox = import "../seatbelt/interface.ncl" in

Sandbox.build {
  id = "standard",
  backend = 'seatbelt,
  cmd = ["/bin/bash"],
  network = { enabled = true, mode = 'localhost },
  fs = {
    mode = 'whitelist,
    allowed_paths = [
      "/Users",
      "/tmp",
      "/private",
      "/var/folders",
      "/usr/local",
    ],
  },
} |> Sandbox.to_profile
```

## CLI Usage

```bash
# Generate
nickel export examples/seatbelt-standard.ncl -f text > profile.sb

# Test
sandbox-exec -f profile.sb /bin/pwd
```
