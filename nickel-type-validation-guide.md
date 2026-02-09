# Nickel Type Validation LLM Guide

> Based on Nickel Stdlib (`stdlib/std.ncl`) and `internals.ncl` - The Purest Nickel Patterns

## Table of Contents

1. [Core Philosophy](#core-philosophy)
2. [Contract Fundamentals](#contract-fundamentals)
3. [Contract Composition Patterns](#contract-composition-patterns)
4. [Label and Error Messaging](#label-and-error-messaging)
5. [Enum Patterns](#enum-patterns)
6. [Array Patterns](#array-patterns)
7. [Record Patterns](#record-patterns)
8. [Function Contracts](#function-contracts)
9. [Polymorphic Contracts](#polymorphic-contracts)
10. [Advanced Patterns](#advanced-patterns)
11. [Complete Examples](#complete-examples)
12. [Quick Reference](#quick-reference)

---

## Core Philosophy

Nickel's contract system is built on **delayed evaluation** and **blame assignment**. Understanding these concepts is crucial:

### Delayed vs Immediate Contracts

```nickel
# Immediate: decided right away
let Immediate = std.contract.from_predicate (fun x => x > 0) in
5 | Immediate  # Checks immediately, returns 5 or errors

# Delayed: can be embedded in values
let Delayed = std.contract.custom (fun label value =>
  'Ok value  # Passes now, but can have subcontracts inside
) in
```

### Blame Assignment

```nickel
# From internals.ncl - basic contract structure
# Contract = fun label value => [| 'Ok Dyn, 'Error { message, notes, .. } |]

# Correct pattern
let MyContract = std.contract.custom (fun label value =>
  if value > 0 then
    'Ok value
  else
    'Error { message = "expected positive number" }
) in
```

---

## Contract Fundamentals

### from_predicate vs custom

```nickel
# 1. from_predicate - Simple boolean checks
# Returns 'Ok value or 'Error {}
let IsZero = std.contract.from_predicate (fun x => x == 0) in
0 | IsZero  # => 0

# 2. custom - Full control (The Gold Standard)
# Full access to label, can push subcontracts and return custom messages
let IsPositive = std.contract.custom (fun label x =>
  if x > 0 then
    'Ok x
  else
    'Error { message = "expected positive number, got %{std.to_string x}" }
) in
5 | IsPositive  # => 5
```

### Type Contracts (from internals.ncl)

```nickel
# Builtin contracts are just functions returning [| 'Ok, 'Error |]
# From internals.ncl - $num contract
let "$num" = fun _label value =>
  if %typeof% value == 'Number then
    'Ok value
  else
    'Error {}
in
5 | "$num"  # => 5

# $string contract
let "$string" = fun _label value =>
  if %typeof% value == 'String then
    'Ok value
  else
    'Error {}
in
"hello" | "$string"  # => "hello"

# $bool contract
let "$bool" = fun _label value =>
  if %typeof% value == 'Bool then
    'Ok value
  else
    'Error {}
in
true | "$bool"  # => true
```

---

## Contract Composition Patterns

### Sequence - Apply Multiple Contracts

```nickel
# Apply contracts left to right
let C = std.contract.Sequence [Number, std.contract.from_predicate (fun x => x > 0)] in
5 | C  # => 5

# Equivalent to:
# (5 | Number) | Positive

# Common pattern from stdlib: Combine checks
let PositiveNumber = std.contract.Sequence [
  Number,
  std.contract.from_predicate (fun x => x >= 0)
] in
```

### any_of - At Least One Matches

```nickel
# From stdlib - accepts if ANY contract passes
let Date = std.contract.any_of [
  String,
  { day | Number, month | Number, year | Number }
] in
{ day = 1, month = 1, year = 1970 } | Date  # => passes

# Implementation pattern (from stdlib)
let any_of = fun contracts =>
  %contract/custom% (fun label value =>
    std.array.try_fold_left
      (fun _acc Contract =>
        let label = %label/with_message%
          "any_of: a delayed check of the picked branch failed"
          label
        in
        std.contract.check Contract label value
        |> match {
          'Ok value => 'Error value,  # Short-circuit on success
          'Error msg => 'Ok msg       # Continue on failure
        }
      )
      ('Ok null)
      contracts
    |> match {
      'Ok _ =>
        'Error { message = "any_of: didn't match any contract" },
      'Error value => 'Ok value,
    }
  )
in
```

### all_of - All Must Match

```nickel
# all_of is just Sequence
let AllOf = std.contract.all_of [Number, String] in
# This will always fail since value can't be both

# Proper use: combining multiple constraints on same type
let BoundedNumber = std.contract.all_of [
  std.contract.from_predicate (fun x => x >= 0),
  std.contract.from_predicate (fun x => x <= 100)
] in
50 | BoundedNumber  # => 50
```

### not - Negation

```nickel
# Accept if contract FAILS immediately
let NotNumber = std.contract.not Number in
"hello" | NotNumber  # => "hello"

# Note: only works on immediate parts
# Delayed checks may not be caught
```

---

## Label and Error Messaging

### Label Module (from stdlib)

```nickel
# Labels track error diagnostics for detailed error messages
# They form a stack for nested contract violations

# with_message - Set main error message
let FooIsEven = std.contract.custom (fun label =>
  match {
    record @ { foo, .. } =>
      'Ok (
        std.record.map (fun key value =>
          if key == "foo" && !(std.is_number value && value % 2 == 0) then
            label
            |> std.contract.label.with_message "field foo must be an even number"
            |> std.contract.blame
          else
            value
        )
        record
      ),
    _ => 'Error {},
  }
) in
```

### append_note - Add Additional Context

```nickel
# Add explanatory notes to errors
let StrictNumber = std.contract.custom (fun label value =>
  if value > 0 then
    'Ok value
  else
    label
    |> std.contract.label.append_note "Number must be positive for this operation"
    |> std.contract.blame
) in
```

### check vs apply

```nickel
# apply - Aborts on failure with blame error
# Use for top-level contracts
let result = std.contract.apply Number label value
# If fails: throws blame error

# check - Returns 'Ok or 'Error
# Use for subcontracts (returns same type as custom contracts)
let Nullable = fun Contract =>
  std.contract.custom (fun label value =>
    if value == null then
      'Ok value
    else
      std.contract.check Contract label value  # Returns [| 'Ok, 'Error |]
  )
in
```

---

## Enum Patterns

### Enum Type Definition and Contracts

```nickel
# Define enum type (1.x syntax)
EventType = [|
  'push,
  'pull_request,
  'workflow_dispatch,
  'schedule
|]

# Using in contract
event_type | EventType

# Enum contracts from internals.ncl
let "$enum" = fun matcher =>
  fun label value =>
    if %typeof% value == 'Enum then
      matcher label value
    else
      'Error { message = "expected an enum" }
in

# Enum variant contract
let "$enum_variant" = fun tag =>
  fun _label value =>
    if %enum/is_variant% value then
      let value_tag = %enum/get_tag% value in
      if value_tag == tag then
        'Ok value
      else
        'Error { message = "expected `'%{tag}`, got `'%{value_tag}`" }
    else
      'Error { message = "expected an enum variant" }
in
```

### TagOrString - Accept Both Tags and Strings

```nickel
# From stdlib - converts strings to enum tags automatically
let TagOrString =
  %contract/custom% (fun _label value =>
    %typeof% value
    |> match {
      'String => 'Ok (%enum/from_string% value),
      'Enum if !(is_enum_variant value) => 'Ok value,
      _ => 'Error { message = "expected either a string or an enum tag" },
    }
  )
in

# Usage: accepts "http" or 'http
{
  protocol | std.enum.TagOrString | [| 'http, 'https |],
  port | Number,
} | {
  protocol = "http",  # Converted to 'http
  port = 443,
}
```

### Enum Helpers

```nickel
# Check if bare tag (not variant)
std.enum.is_enum_tag 'foo  # => true
std.enum.is_enum_tag ('Foo "arg")  # => false

# Check if variant (has argument)
std.enum.is_enum_variant ('Foo "arg")  # => true
std.enum.is_enum_variant 'foo  # => false

# Convert between formats
std.enum.to_tag_and_arg ('Foo "arg")  # => { tag = "Foo", arg = "arg" }
std.enum.from_tag_and_arg { tag = "Foo", arg = "arg" }  # => ('Foo "arg")
```

---

## Array Patterns

### Array Contract (from internals.ncl)

```nickel
# $array - parameterized element contract
let "$array" = fun Element =>
  fun label value =>
    if %typeof% value == 'Array then
      'Ok (
        %contract/array_lazy_apply%
          (%label/go_array% label)
          value
          Element
      )
    else
      'Error { message = "expected an array" }
in

# Usage
let NumberArray = "$array" Number in
[1, 2, 3] | NumberArray  # => passes
```

### NonEmpty Array

```nickel
# From stdlib - enforces non-empty array
let NonEmpty =
  %contract/custom% (fun _label value =>
    if %typeof% value == 'Array then
      if %array/length% value != 0 then
        'Ok value
      else
        'Error { message = "empty array" }
    else
      'Error { message = "not an array" }
  )
in

# Use with ArrayOf
let NonEmptyNumberArray = std.contract.Sequence [
  NonEmpty,
  js2n.array.ArrayOf Number
] in
```

### Flatten and Transform Contracts

```nickel
# Using fold for complex array validation
let UniqueArray = fun Contract =>
  std.contract.from_validator (fun arr =>
    let seen = std.array.fold_left
      (fun acc x =>
        if acc == null then
          { seen = [x], is_unique = true }
        else if std.array.elem x acc.seen then
          acc & { is_unique = false }
        else
          acc & { seen = acc.seen @ [x] }
      )
      { seen = [], is_unique = true }
      arr
    in
    if seen.is_unique then
      'Ok
    else
      'Error { message = "array contains duplicates" }
  )
in
```

---

## Record Patterns

### Record Contract (from internals.ncl)

```nickel
# $record_contract - main record contract implementation
let "$record_contract" = fun record_contract =>
  fun label value =>
    if %typeof% value == 'Record' then
      %record/merge_contract% label value record_contract
    else
      'Error { message = "expected a Record" }
in

# $dict_type - dictionary with typed values
let "$dict_type" = fun Contract =>
  fun label value =>
    if %typeof% value == 'Record' then
      'Ok (
        %record/map%
          value
          (fun _field field_value =>
            %contract/apply% Contract (%label/go_dict% label) field_value
          )
      )
    else
      'Error { message = "not a record" }
in
```

### Field Requirements

```nickel
# Required fields - record type syntax
{
  name | String,
  email | String,  # Required by default
} | { name = "John", email = "john@example.com" }

# Optional fields
{
  name | String,
  age | Number | optional,
}

# Extra fields allowed (wildcard)
{
  name | String,
  _ | Dyn,  # Accept any extra fields
}
```

### Dictionary Contracts

```nickel
# { _ : T } - all values must be type T
{
  users | { _ : { name | String, age | Number } },
}

# { _ | T } - metadata contracts on values
{
  config | { _ | optional },
}

# Combination
{
  headers | { _ : String },
}
```

---

## Function Contracts

### Function Contract (from internals.ncl)

```nickel
# $func - domain -> codomain contract
let "$func" = fun Domain Codomain =>
  fun label value =>
    if %typeof% value == 'Function' then
      'Ok (fun x =>
        %contract/apply%
          Codomain
          (%label/go_codom% label)
          (value (%contract/apply% Domain (%label/flip_polarity% (%label/go_dom% label)) x))
      )
    else
      'Error { message = "expected a function" }
in

# Example: predicate contract
let EvenPredicate = {
  _ | (Number -> Bool)  # Function from number to bool
} in
let is_even = fun n => n % 2 == 0 in
is_even | EvenPredicate  # => passes
```

---

## Polymorphic Contracts

### forall Contracts (from internals.ncl)

```nickel
# $forall_var - polymorphic variable handling
let "$forall_var" = fun sealing_key =>
  fun label value =>
    let current_polarity = %label/polarity% label in
    let polarity = (%label/lookup_type_variable% sealing_key label).polarity in
    if polarity == current_polarity then
      'Ok (%unseal% sealing_key value (%blame% label))
    else
      'Ok (%seal% sealing_key (%label/flip_polarity% label) value)
in

# Generic identity function contract
# forall a. a -> a
```

### Record Tail Contracts

```nickel
# $forall_record_tail - polymorphic record tails
# Handles extra fields in records with type variables
```

---

## Advanced Patterns

### Lazy Contract Application

```nickel
# Records and arrays have lazy evaluation
# Contract checks are delayed until values are forced

let LazyRecord = {
  validated | {
    name | String,
    age | Number | optional,
  }
} in
{
  validated = {
    name = "John",
    # age not checked until accessed
  }
} | LazyRecord
```

### Sealing and Unsealing

```nickel
# From internals.ncl - polymorphism mechanism
# Used internally for forall contracts
# Not typically needed in user code
```

### Custom Error Recovery

```nickel
# try_fold_left for early termination
let find_first = fun pred xs =>
  let f = fun _acc x =>
    if pred x then 'Error x else 'Ok null
  in
  std.array.try_fold_left f null xs
  |> match {
    'Ok _ => 'None,
    'Error x => 'Some x,
  }
in
find_first (fun x => x > 5) [1, 3, 7, 2]  # => 'Some 7
```

---

## Inline Contracts Pattern (AWS Style)

The cleanest pattern for user-facing interfaces is **inline contracts** - embedding contracts directly in record definitions without wrapping them in `from_predicate`.

### Basic Pattern

```nickel
# interface.ncl - User-facing contracts
{
  ResourceLimits = {
    max_memory_mb | Number,
    max_cpu_seconds | Number,
    ..
  },

  NetworkConfig = {
    enabled | Bool,
    mode | [|'deny, 'localhost, 'container|],
    ..
  },
}

# config.ncl - Usage
let Sandbox = import "interface.ncl" in
{
  resources = { max_memory_mb = 256, max_cpu_seconds = 60 } | Sandbox.ResourceLimits,
  network = { enabled = true, mode = 'localhost } | Sandbox.NetworkConfig,
}
```

### Key Points

1. **`..` allows extra fields** - Records can have more fields than just those listed in the contract
2. **Inline enums** - Use `|'tag` directly in the record
3. **No wrapping needed** - `{ field | Type }` is already a contract
4. **Composable** - Contracts can be used anywhere with `| ContractName`

### Open vs Closed Records

```nickel
# Open (allows extra fields) - Use `..`
{
  name | String,
  age | Number,
  ..
} | { name = "John" }

# Closed (strict) - No `..`
{
  name | String,
  age | Number,
} | { name = "John", age = 30 }
```

### When to Use

- **User interfaces**: Always use `..` for flexibility
- **Internal APIs**: May omit `..` for strict validation
- **Default values**: Use at call site with `| default = {...}`

```nickel
# With defaults at call site
{
  resources = {
    max_memory_mb = 256,
    max_cpu_seconds = 60,
  } | Sandbox.ResourceLimits | default = {
    max_memory_mb = 128,
    max_cpu_seconds = 30,
    max_file_size_mb = 10,
    ..
  },
}
```

---

## Complete Examples

### Sandbox Backend Contract (Pure Nickel Style)

```nickel
# packages/ncl/sandbox/backends/contract.ncl

{
  # NonEmptyStringArray - validated array
  NonEmptyStringArray
    | doc m%"An array of non-empty strings"%
    = std.contract.from_predicate (fun value =>
      std.is_array value
      && std.array.all (fun x => std.is_string x && std.string.length x > 0) value
    ),

  # BackendFeatures - feature flags
  FeaturesContract
    | doc m%"Sandbox backend feature flags"%
    = {
      seccomp | Bool,
      cgroups | Bool,
      namespaces | Bool,
      network_isolation | Bool,
    },

  # BackendConfig - complete backend configuration
  BackendContract
    | doc m%"Validates backend configuration"%
    = {
      name | String,
      supported_platforms | NonEmptyStringArray,
      supported_profiles | NonEmptyStringArray,
      supported_features | FeaturesContract,
      default_timeout_seconds | Number,
    },

  # Platform-specific backends
  nsjail_backend
    | doc m%"NSJail backend for Linux"%
    = {
      name = "nsjail",
      supported_platforms = ["linux"],
      supported_profiles = ["strict", "standard", "relaxed"],
      supported_features = {
        seccomp = true,
        cgroups = true,
        namespaces = true,
        network_isolation = true,
      },
      default_timeout_seconds = 60,
    } | BackendContract,

  seatbelt_backend
    | doc m%"Seatbelt backend for macOS"%
    = {
      name = "seatbelt",
      supported_platforms = ["macos"],
      supported_profiles = ["strict", "standard"],
      supported_features = {
        seccomp = false,
        cgroups = false,
        namespaces = false,
        network_isolation = true,
      },
      default_timeout_seconds = 60,
    } | BackendContract,
}
```

### Sandbox Interface with Rich Contracts

```nickel
# packages/ncl/sandbox/interface.ncl

{
  ResourceLimits
    | doc m%"Resource constraints for sandbox execution"%
    = {
      max_memory_mb | std.contract.from_predicate (fun x =>
        std.is_number x && x > 0
      ),
      max_cpu_percent | std.contract.from_predicate (fun x =>
        std.is_number x && x > 0 && x <= 100
      ),
      timeout_seconds | std.contract.from_predicate (fun x =>
        std.is_number x && x > 0 && x <= 3600
      ),
    },

  NetworkMode
    | doc m%"Network isolation mode"%
    = std.contract.any_of [
      std.contract.Const "deny",
      std.contract.Const "bridge",
      std.contract.Const "nat",
    ],

  NetworkConfig
    | doc m%"Network configuration"%
    = {
      enabled | Bool,
      mode | NetworkMode,
      allowed_hosts | Array String | optional,
    },

  SandboxProfile
    | doc m%"Sandbox profile with resources and config"%
    = {
      name | String,
      resources | ResourceLimits,
      network | NetworkConfig | optional,
    },
}
```

### Custom Validation Contract

```nickel
# packages/ncl/sandbox/validation.ncl

{
  # Password strength validator
  PasswordStrength
    | doc m%"Validates password meets minimum requirements"%
    = std.contract.from_validator (fun password =>
      if !std.is_string password then
        'Error { message = "password must be a string" }
      else
        let length = std.string.length password in
        let checks = [
          { valid = length >= 8, msg = "at least 8 characters" },
          { valid = std.string.is_match "[A-Z]" password, msg = "one uppercase letter" },
          { valid = std.string.is_match "[a-z]" password, msg = "one lowercase letter" },
          { valid = std.string.is_match "[0-9]" password, msg = "one digit" },
        ]
        |> std.array.filter (fun c => !c.valid)
        |> std.array.map (fun c => c.msg)
        in
        if checks == [] then
          'Ok
        else
          'Error {
            message = "password validation failed: %{std.string.join ", " checks}",
          }
    ),

  # Date range validator
  DateRange
    | doc m%"Validates end_date is after start_date"%
    = std.contract.from_validator (fun value =>
      if value.end_date > value.start_date then
        'Ok
      else
        'Error {
          message = "end_date must be after start_date",
          notes = [
            "start_date: %{value.start_date}",
            "end_date: %{value.end_date}",
          ],
        }
    ),
}
```

---

## Quick Reference

### Contract Builders

| Function | Returns | Use When |
|----------|---------|----------|
| `from_predicate (fun x => ...)` | `\| Contract` | Simple boolean checks |
| `from_validator (fun x => ...)` | `\| Contract` | Need custom error messages |
| `custom (fun label value => ...)` | `\| Contract` | Full control, subcontracts |

### Label Operations

| Operation | Purpose |
|-----------|---------|
| `label.with_message "msg"` | Set main error message |
| `label.append_note "note"` | Add context note |
| `label.with_notes ["a", "b"]` | Set multiple notes |
| `apply Contract label value` | Apply contract, abort on fail |
| `check Contract label value` | Apply, return `'Ok/'Error` |

### Array Operations in Contracts

| Primop | Purpose |
|--------|---------|
| `%array/length%` | Get array length |
| `%array/at%` | Get element at index |
| `%array/map%` | Transform elements |
| `%array/generate%` | Generate array lazily |
| `%contract/array_lazy_apply%` | Apply contract to elements |

### Record Operations in Contracts

| Primop | Purpose |
|--------|---------|
| `%record/fields%` | Get field names |
| `%record/map%` | Transform field values |
| `%record/split_pair%` | Compare fields |
| `%record/merge_contract%` | Apply record contract |
| `%record/has_field%` | Check field exists |

### Enum Operations

| Primop / Function | Purpose |
|--------------------|---------|
| `%enum/is_variant%` | Check if has argument |
| `%enum/get_tag%` | Get tag name |
| `%enum/get_arg%` | Get argument value |
| `%enum/from_string%` | String to tag |
| `std.enum.TagOrString` | Accept both |
| `std.enum.is_enum_tag` | Check bare tag |

### Type Checks

| Function | Purpose |
|----------|---------|
| `std.is_number x` | Check Number type |
| `std.is_string x` | Check String type |
| `std.is_bool x` | Check Bool type |
| `std.is_enum x` | Check Enum type |
| `std.is_array x` | Check Array type |
| `std.is_function x` | Check Function type |
| `std.is_record x` | Check Record type |

---

## Key Learnings from Stdlib

1. **Use `custom` for advanced contracts** - `from_predicate` and `from_validator` are simpler but limited

2. **Label manipulation for errors** - Stack diagnostics for nested contract violations

3. **Delayed contracts** - Records and arrays have lazy evaluation, contracts propagate inside

4. **Polymorphism via sealing** - Internal mechanism for `forall` contracts

5. **Enum vs Tag vs Variant** - Understand the difference for proper contracts

6. **check vs apply** - Use `check` for subcontracts, `apply` at top level

7. **Type primops** - Use `%typeof%`, `%array/*`, `%record/*` for introspection

---

## 13. Pure Nickel vs. Generated Schemas

When using `json-schema-to-nickel`, the resulting code often mimics the functional, predicate-based validation of JSON Schema. While robust, this can be more verbose and harder to read than native Nickel contracts.

### Why Native Contracts are Better:
1. **Performance**: Native contracts (like `{ name | String }`) are optimized by the Nickel interpreter.
2. **Readability**: Native contracts are more concise and idiomatic.
3. **Integration**: Native contracts integrate better with Nickel's type checking and error reporting.
4. **Laziness**: Native record contracts are lazy by default, only validating fields when they are accessed.

**Best Practice**: Use generated schemas for existing JSON Schema assets, but favor native Nickel contracts and `std.contract.custom` for new development.

For more on this, see [Nickel Best Practices](nickel-best-practices.md).

---

## References

- Nickel Stdlib: `stdlib/std.ncl`
- Internals: `stdlib/internals.ncl`
- Nickel Manual: Contract chapter
