# Network Policies Reference

Network isolation configurations for nsjail.

## Available Policies

```nickel
let nsjail = import "../../sandbox/nsjail/main.ncl" in

{
  network_policy = nsjail.network.deny,
}
```

| Policy | Description |
|--------|-------------|
| `deny` | All network access blocked |
| `localhost` | Localhost only (127.0.0.1) |
| `container` | Container networking |
| `allow` | Full network access |

## Usage Examples

### Deny All

```nickel
network_policy = nsjail.network.deny,
```

### Localhost Only

```nickel
network_policy = nsjail.network.localhost,
```

### Full Access

```nickel
network_policy = nsjail.network.allow,
```
