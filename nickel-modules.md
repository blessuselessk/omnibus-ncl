# Nickel Module System Architecture

> **Foundation Document**: This document describes the core architecture and code organization patterns of the Nickel module system.
> **Companion Documents**:
> - [Nickel Interface Style Guide](nickel-interface-style.md) - User interface design patterns (based on Organist Schema-Config)
> - [Nickel Best Practices](nickel-best-practices.md) - Code style and LLM notes
> - [Nickel Type Validation Guide](nickel-type-validation-guide.md) - Advanced contracts and type validation
> - [Nickel Language Handbook (LLM Edition)](nickel-language-handbook-llm.md) - Language basics quick reference

---

## Core Principles

1. **Export Only Data** - Functions cannot be serialized, keep logic and data separate
2. **Schema-Config Separation** - Define types (contracts) alongside values, see [Organist Interface Pattern](nickel-interface-style.md)
3. **Record Merging** - Use `&` for incremental configuration
4. **Contract Composition** - Layer contracts for defense-in-depth validation
5. **Avoid Recursion** - Prohibit `field = field` (causes infinite recursion)

---

## 1. Module Architecture Patterns

### Organist T Type Pattern (Recommended)

All modules should follow Organist's `T` type pattern, which is the foundation of user interface design:

```nickel
# lib/module.ncl
{
  Schema | { .. } | not_exported = {
    # Contract definitions (not exported to JSON)
    name | String,
    enabled | Bool | default = true,
  },
  config | Schema = {
    # Default configuration
    name = "default",
  },
}
```

For detailed explanation, see [Schema-Config Separation Pattern](nickel-interface-style.md#2-the-module-pattern).

### Simple Export Pattern (Library Modules)

For internal library modules, use simple exports:

```nickel
# lib/main.ncl
{
  rlimits = import "rlimits.ncl",
  network = import "network.ncl",
  mounts = import "mounts.ncl",
}
```

---

## 2. Module Directory Structure

```
sandbox/
├── main.ncl              # Main export
├── lib/
│   ├── main.ncl          # Submodule aggregation
│   ├── rlimits.ncl       # Resource limits module
│   ├── network.ncl       # Network policy module
│   └── mounts.ncl        # Mount configuration module
├── nsjail/               # nsjail configuration
└── skill/                # Skill configuration
```

### Complete Export Example

```nickel
# main.ncl
let Lib = import "lib/main.ncl" in
let Nsjail = import "nsjail/main.ncl" in

{
  version = "1.0.0",
  lib = Lib,
  nsjail = Nsjail,
}
```

---

## 3. Record Merging

The `&` operator is the core of Nickel configuration composition:

```nickel
# Basic merge (right overrides left)
{ a = 1 } & { a = 2 }  # => { a = 2 }

# Deep merge (recursive)
{ outer = { inner = 1 } } & { outer = { new = 2 } }
# => { outer = { inner = 1, new = 2 } }
```

### Shell Composition Pattern

```nickel
Bash = import "./shells/bash.ncl",

Go =
  Bash
  & {
    build.packages.go = import_nix "nixpkgs#go",
  },
```

---

## 4. Contracts and Types

For detailed contract usage, see [Nickel Type Validation Guide](nickel-type-validation-guide.md).

### Basic Contract Patterns

```nickel
# Defense-in-depth path validation
target | std.string.NonEmpty | RelativePath

# Optional fields
field | Type | optional

# Enum types
mode | [|'option_a, 'option_b|]
```

---

## 5. Critical: Avoid Recursion

Nickel detects self-references and throws "infinite recursion" errors.

### Wrong

```nickel
{ large = large }  # Recursive!
```

### Correct

```nickel
{
  minimal = { rlimit_as = 64 * 1024 * 1024 },
  large = { rlimit_as = 512 * 1024 * 1024 },
}
```

---

## 6. Style Conventions

| Pattern | Convention | Example |
|---------|------------|---------|
| Variables | snake_case | `my_variable` |
| Constants | SCREAMING_SNAKE_CASE | `DEFAULT_PORT` |
| Tags | lowercase_single_quoted | `'tab`, `'space` |
| Types/Schemas | PascalCase | `ShellApplication` |
| Modules | snake_case | `shell_utils` |
| Indentation | 2 spaces | See examples |
| Strings | Double quotes | `"value"` |
| Tags | Single quotes | `'option` |

---

## 7. Usage Example

```nickel
let sandbox = import "main.ncl" in

sandbox.lib.rlimits.small
sandbox.lib.network.deny
```

---

## 8. Verification Commands

```bash
# Export verification
nickel export main.ncl

# Format check
nickel format --check lib/*.ncl

# Type check
nls main.ncl
```

---

## References

- [Tweag: Nickel Modules](https://www.tweag.io/blog/2024-06-20-nickel-modules/)
- [Nickel Contracts](https://nickel-lang.org/manual/stable/contracts)
- [Nickel Lang Organist](https://github.com/nickel-lang/organist)
- [Nickel Interface Style Guide](nickel-interface-style.md)
