# Path Matching Reference

Pattern matching for file access in Seatbelt.

## Match Types

### subpath

Directory and all contents:

```sbpl
(allow file-read-data file-write-data (subpath "/usr"))
```

Matches: `/usr`, `/usr/bin`, `/usr/local/bin`

### literal

Exact path match:

```sbpl
(allow file-read-data file-write-data (literal "/tmp/myfile"))
```

Matches: `/tmp/myfile` only

## Common Patterns

### System Directories

```sbpl
(allow file-read-data file-write-data (subpath "/usr/local"))
(allow file-read-data file-write-data (subpath "/usr/lib"))
(allow file-read-data file-write-data (subpath "/System/Library"))
(allow file-read-data file-write-data (subpath "/Library"))
```

### User Directory

```sbpl
(allow file-read-data file-write-data (subpath "/Users/guangtao/projects"))
```

### Temp Directories

```sbpl
(allow file-read-data file-write-data (subpath "/private/tmp"))
(allow file-read-data file-write-data (subpath "/var/folders"))
```

### Python Runtime

```sbpl
(allow file-read-data file-write-data (subpath "/usr/local"))
(allow file-read-data file-write-data (subpath "/usr/lib"))
(allow file-read-data file-write-data (subpath "/System/Library"))
```

## Nickel Config

```nickel
fs = {
  mode = 'whitelist,
  allowed_paths = [
    "/usr/local",
    "/usr/lib",
    "/System/Library",
    "/private/tmp",
    "/var/folders",
  ],
}
```
