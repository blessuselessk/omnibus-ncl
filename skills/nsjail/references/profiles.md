# Nsjail Profile Types

Pre-configured sandbox profiles for different use cases.

## Profile Comparison

| Profile | Network | Resources | Use Case |
|---------|---------|-----------|----------|
| `minimal` | deny | small | Read-only data processing |
| `standard` | localhost | medium | Development tasks |
| `development` | allow | large | Full access debugging |

## Minimal Profile

```nickel
let nsjail = import "../../sandbox/nsjail/main.ncl" in

{
  mode = nsjail.modes.local,
  rlimits = nsjail.rlimits.small,
  network_policy = nsjail.network.deny,
}
```

## Standard Profile

```nickel
let nsjail = import "../../sandbox/nsjail/main.ncl" in

{
  mode = nsjail.modes.network,
  rlimits = nsjail.rlimits.medium,
  network_policy = nsjail.network.localhost,
  mount_policy = nsjail.mounts.standard,
}
```

## Development Profile

```nickel
let nsjail = import "../../sandbox/nsjail/main.ncl" in

{
  mode = nsjail.modes.full,
  rlimits = nsjail.rlimits.large,
  network_policy = nsjail.network.allow,
  mount_policy = nsjail.mounts.development,
}
```

## Resource Limits

| Preset | Memory | CPU | Description |
|--------|--------|-----|-------------|
| `minimal` | 64MB | 10s | Basic operations |
| `small` | 128MB | 30s | Light tasks |
| `medium` | 256MB | 60s | Standard tasks |
| `large` | 512MB | 300s | Heavy tasks |
