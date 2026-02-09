# SBPL Syntax Reference

Sandbox Profile Language syntax for macOS Seatbelt.

## Profile Structure

```sbpl
(version 1)
(allow default)
(allow network-outbound)
(allow network-inbound)
(allow file-read-data file-write-data (subpath "/usr"))
```

## Operations

| Operation | Description |
|-----------|-------------|
| `file-read-data` | Read file contents |
| `file-write-data` | Write file contents |
| `network-outbound` | Network connections out |
| `network-inbound` | Network connections in |
| `process-exec*` | Execute binaries |

## Path Matchers

| Matcher | Example |
|---------|---------|
| `literal` | `(literal "/tmp/file")` - Exact path |
| `subpath` | `(subpath "/usr")` - Directory and children |

## Actions

| Action | Description |
|--------|-------------|
| `allow` | Permit operation |
| `deny` | Block operation |

## Common Patterns

### Allow Network

```sbpl
(allow network-outbound)
(allow network-inbound)
```

### Deny Network

```sbpl
(deny network-outbound)
(deny network-inbound)
```

### Allow File Access

```sbpl
(allow file-read-data file-write-data (subpath "/Users/guangtao/projects"))
```

### Allow Python Runtime

```sbpl
(allow file-read-data file-write-data (subpath "/usr/local"))
(allow file-read-data file-write-data (subpath "/usr/lib"))
(allow file-read-data file-write-data (subpath "/System/Library"))
(allow file-read-data file-write-data (subpath "/private/tmp"))
```

## Generated Profile Example

```sbpl
(version 1)
(allow default)
(allow network-outbound)
(allow network-inbound)
(allow file-read-data file-write-data (subpath "/Users/guangtao/projects"))
(allow file-read-data file-write-data (subpath "/usr/local"))
(allow file-read-data file-write-data (subpath "/usr/lib"))
(allow file-read-data file-write-data (subpath "/System/Library"))
(allow file-read-data file-write-data (subpath "/private/tmp"))
(allow file-read-data file-write-data (subpath "/var/folders"))
```
