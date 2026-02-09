# Nickel Interface Style Guide

> **Authority Guide**: This document is the authoritative guide for Nickel user interface design, based on the [Organist](https://github.com/nickel-lang/organist) project.
> **Companion Documents**:
> - [Nickel Module System](nickel-modules.md) - Module system architecture (Foundation Document)
> - [Nickel Best Practices](nickel-best-practices.md) - Code style and LLM notes
> - [Nickel Type Validation Guide](nickel-type-validation-guide.md) - Advanced contracts and type validation

---

## 1. Core Principle: Schema-Config Separation

The fundamental pattern in Nickel interface design is separating **what users configure** from **how it's validated**.

```nickel
# module.ncl - Organist pattern
{
  Schema = {
    name | String,
    enabled | Bool | default = true,
  },
  config | Schema = {
    name = "my-service",
  },
}
```

### Why This Works

- **Schema**: Defines contracts, types, defaults, and documentation
- **Config**: The actual user-provided values
- **Validation**: `config | Schema` validates config against Schema

---

## 2. The Module Pattern

Organist's module pattern defines a clean interface structure:

```nickel
# lib/module.ncl
{
  Schema | { .. } | not_exported = {
    # Contract definitions here
    option_a | String,
    option_b | Number | default = 42,
  },
  config | Schema = {
    # Default configuration
    option_a = "default",
  },
}
```

### Key Elements

| Element | Purpose |
|---------|----------|
| `Schema` | Contract definitions with doc comments |
| `Schema \| { .. }` | Allows extra fields in Schema |
| `Schema \| not_exported` | Schema won't be exported to JSON |
| `config \| Schema` | Validates config against Schema |
| `config \| Schema = {}` | Config with defaults |

---

## 3. Composable Modules with `&`

Combine modules using the merge operator `&`:

```nickel
# project.ncl
let organist = inputs.organist in

organist.OrganistExpression
& organist.tools.editorconfig
& organist.tools.direnv
& {
  Schema,
  config | Schema = {
    shells = organist.shells.Bash,
  },
}
```

This creates a **layered configuration** where each module contributes its Schema and config.

---

## 4. Documentation Pattern

Always document interfaces using `| doc m%"..."%`:

```nickel
{
  MyOption
    | doc m%"
        A short description of what this option controls.

        # Examples

        ```nickel
        ({ value = "example" } | MyOption)
        # => { value = "example" }
        ```
      "%
    = { value | String },
}
```

### Documentation Rules

1. **Brief description** - One line explaining the option
2. **Blank line** - Separate description from examples
3. **# Examples section** - Show usage patterns
4. **Code blocks** - Use ```nickel ```
5. **Expected output** - Use `# => value`

---

## 5. Contract Composition

Layer contracts for defense-in-depth validation:

```nickel
# Validates: is string, non-empty, doesn't start with "/"
let FilePath =
  std.string.NonEmpty
  | std.contract.from_predicate (fun x => std.string.starts_with "/" |> std.function.flip x)
in

{ path | FilePath }
```

### Common Contract Patterns

```nickel
# Type + custom predicate
field | String | default = "value"

# Optional field
field | Type | optional

# Enum-like
field | [| 'option_a, 'option_b |]

# Record with schema
config | { field | String, .. }
```

---

## 6. Type Annotations vs Contracts

Nickel has both static types and runtime contracts:

```nickel
{
  # Static type (for typechecking only)
  my_function : forall a. Array a -> a

  # Contract (for runtime validation)
  my_value | MyContract -> Dyn

  # Both (recommended for complex cases)
  complex_function : forall a. Array a -> a
  | NonEmptyArray -> Dyn
}
```

### When to Use Each

| Static Types (`: Type`) | Contracts (`| Contract`) |
|-------------------------|------------------------|
| Generic type inference | Runtime validation |
| Function signatures | Custom predicates |
| Structural checking | Domain-specific rules |
| IDE support | User-facing contracts |

---

## 7. Function Design

Design functions for composability:

```nickel
# Pure function - easy to test and compose
let add_prefix = fun prefix => fun value =>
  "%{prefix}-%{value}"
in

# Curried for partial application
let with_prefix = add_prefix "PREFIX" in
with_prefix "hello"  # => "PREFIX-hello"
```

### Pipeline-Friendly Functions

```nickel
let process = fun data =>
  data
  |> std.record.filter (fun _ v => v != null)
  |> std.record.map (fun k v => { key = k, value = v })
```

---

## 8. Extensibility Patterns

### Open Records with `..`

```nickel
{
  Schema = {
    required_field | String,
    optional_field | Number | optional,
    ..  # Allows extra fields
  },
}
```

### Forward Declaration

```nickel
{
  Schema = {
    forward_declared | Type,
    another_field | forward_declared,
  },
}
```

---

## 9. Module Organization

### Standard Library Structure (Organist Style)

```
lib/
├── main.ncl              # Aggregates all modules
├── module_a.ncl          # Standalone module
├── module_b.ncl          # Standalone module
└── subdir/
    ├── nested.ncl        # Nested module
    └── main.ncl          # Aggregates nested modules
```

### Main Module Export

```nickel
# lib/main.ncl
{
  module_a = import "module_a.ncl",
  module_b = import "module_b.ncl",
  nested = import "subdir/main.ncl",
}
```

---

## 10. Error Messages

Design contracts to produce helpful error messages:

```nickel
# Good: Specific error message
let PortNumber = std.contract.from_predicate (fun label value =>
  if value < 1 || value > 65535 then
    std.contract.blame_with_message "Port must be between 1-65535" label
  else
    value
)
in

# Usage
(8080 | PortNumber)  # Works
(70000 | PortNumber)  # Error: Port must be between 1-65535
```

---

## 11. Complete Example: A Sandbox Interface

```nickel
# interface.ncl - Sandbox configuration interface

{
  # ============================================
  # Schema: Contract definitions
  # ============================================
  Schema = {
    name | String | doc "Sandbox instance name",

    backend
      | [| 'nsjail, 'seatbelt, 'hyperlight |]
      | doc "Sandbox backend to use"
      | default = 'nsjail,

    resources
      | {
          max_memory_mb | Number,
          max_cpu_seconds | Number,
          ..
        }
      | doc "Resource limits"
      | default = {
          max_memory_mb = 512,
          max_cpu_seconds = 30,
        },

    enabled | Bool | doc "Enable sandbox" | default = true,
  },

  # ============================================
  # Config: Default configuration
  # ============================================
  config | Schema = {
    name = "default",
  },
}
```

### Usage

```nickel
# project.ncl
let Sandbox = import "interface.ncl" in

Sandbox
& {
  Schema,
  config | Schema = {
    name = "my-sandbox",
    backend = 'nsjail,
    resources.max_memory_mb = 1024,
  },
}
```

---

## 12. Anti-Patterns to Avoid

### 1. Missing Defaults

```nickel
# Bad: No defaults, user must provide everything
{ field | String }

# Good: Sensible defaults
{ field | String | default = "unknown" }
```

### 2. Implicit Validation

```nickel
# Bad: No contracts, silent failures
{ name = get_name() }

# Good: Explicit contracts
{ name | NonEmptyString | default = "unnamed" }
```

### 3. Tight Coupling

```nickel
# Bad: Hardcoded values
{ path = "/etc/config" }

# Good: Configurable with defaults
{ path | FilePath | default = "/etc/config" }
```

### 4. Missing Documentation

```nickel
# Bad: No documentation
{ option | String }

# Good: Documented
{ option | String | doc "A crucial setting" }
```

---

## 13. Summary Checklist

When designing a Nickel interface:

- [ ] Schema-Config separation pattern
- [ ] `| doc m%"..."%` on all public fields
- [ ] Sensible defaults with `| default = value`
- [ ] Type annotations for functions
- [ ] Composable with `&` operator
- [ ] Open records (`..`) for extensibility
- [ ] Helpful error messages in contracts
- [ ] Module exports via `main.ncl`
- [ ] Test with `nickel export`
- [ ] Document examples with `# =>`

---

## References

- [Organist](https://github.com/nickel-lang/organist) - Nickel-based project management
- [Nickel stdlib](https://github.com/nickel-lang/nickel) - Standard library patterns
- [Nickel contracts](https://nickel-lang.org/user-guide/contracts/) - Contract system
- [Nickel Module System](nickel-modules.md) - Module system architecture

---

## Related Documents

| Document | Purpose |
|----------|---------|
| [Nickel Module System](nickel-modules.md) | Module system architecture and code organization |
| [Nickel Best Practices](nickel-best-practices.md) | Code style and LLM notes |
| [Nickel Type Validation Guide](nickel-type-validation-guide.md) | Advanced contracts and type validation |
