# Resource Limits Reference

CPU and memory constraints for nsjail.

## Available Presets

```nickel
let nsjail = import "../../sandbox/nsjail/main.ncl" in

{
  rlimits = nsjail.rlimits.small,
}
```

| Preset | rlimit_as | rlimit_cpu | Description |
|--------|-----------|------------|-------------|
| `minimal` | 64MB | 10s | Single operation |
| `small` | 128MB | 30s | Short tasks |
| `medium` | 256MB | 60s | Normal tasks |
| `large` | 512MB | 300s | Extended tasks |

## Custom Limits

```nickel
{
  rlimit_as = 256 * 1024 * 1024,  # 256MB
  rlimit_cpu = 60,                 # 60 seconds
}
```

## Environment Variables

| Variable | Description |
|----------|-------------|
| `TIMEOUT_SECONDS` | Execution timeout |
| `MAX_MEMORY_MB` | Memory limit |
