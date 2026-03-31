# Nickel Language Best Practices

> **Supplementary Document**: Code style and LLM notes.
> **Companion Documents**:
>
> - [Nickel Interface Style Guide](nickel-interface-style.md) - User interface design patterns (Authority Guide)
> - [Nickel Module System](nickel-modules.md) - Module system architecture
> - [Nickel Type Validation Guide](nickel-type-validation-guide.md) - Advanced contracts and type validation

This document covers Nickel code writing best practices, including code style, common LLM pitfalls, and more.

______________________________________________________________________

## 1. Core Philosophy: The Nickel Way

Nickel is not just "JSON with types." It is a functional programming language designed for configuration.

### 1.1 Favor Contracts over "Just Types"

While Nickel has a static type system, **Contracts** are its superpower. Use them for complex invariants that static types cannot capture.

- **Static Types (`:`)**: Use for basic structural integrity (e.g., `Number`, `String`, `Array T`).
- **Contracts (`|`)**: Use for domain-specific validation (e.g., `PortNumber`, `ValidPath`, `NonEmptyArray`).

### 1.2 Embrace Laziness

Nickel is lazy. This allows you to:

- Define recursive structures.
- Defer expensive computations.
- Build configurations where fields depend on each other through merging.

### 1.3 Prefer Enums/Tags over Strings

Instead of using strings for "types" or "modes", use **Enum Tags** (`'tag`). They are more efficient, provide better error messages, and allow for powerful pattern matching.

______________________________________________________________________

## 2. Module System & Architecture

### 2.1 The "Clean Export" Pattern

Avoid exporting functions that cannot be serialized if your goal is to generate JSON/YAML. Separate your **Logic** (functions) from your **Data** (final configuration).

```nickel
# lib/utils.ncl
{
  # Helpers (Logic)
  to_mb = fun bytes => bytes / 1024 / 1024,
  
  # Constants (Data)
  DEFAULT_PORT = 8080,
}
```

### 2.2 Schema-Config Separation

Define your schemas (contracts) in one place and your actual configuration in another.

```nickel
# interface.ncl
let Schema = {
  port | Number | default = 8080,
  host | String,
} in { Schema = Schema }

# config.ncl
let Interface = import "interface.ncl" in
{
  host = "localhost",
} | Interface.Schema
```

详细用法参考 [Nickel Interface Style Guide](nickel-interface-style.md#3-composable-modules-with-).

### 2.4 Modular Composition via Merging (`&`)

详细用法参考 [Nickel Interface Style Guide](nickel-interface-style.md#3-composable-modules-with-).

```nickel
let base = { timeout = 30, retries = 3 } in
let dev = base & { timeout = 10 } in
let prod = base & { retries = 10 } in
...
```

______________________________________________________________________

## 3. Advanced Validation & Contracts

### 3.1 Custom Contracts for Business Logic

Don't settle for simple type checks. Use `std.contract.custom` to implement complex validation.

```nickel
let DateRange = std.contract.custom (fun label value =>
  if value.start_date < value.end_date then
    'Ok value
  else
    'Error { message = "start_date must be before end_date" }
) in

{ start_date = 20240101, end_date = 20230101 } | DateRange # Fails!
```

### 3.2 Polymorphic Record Contracts

Use row polymorphism to write functions or contracts that work on any record with specific fields.

```nickel
# Accepts any record that HAS a 'name' field
let HasName = forall r. { name : String | r } in

let greet = fun obj : HasName => "Hello, %{obj.name}" in
greet { name = "Alice", age = 30 } # Works!
```

### 3.3 Leveraging `std.contract.any_of` and `all_of`

Compose contracts to create flexible validation rules.

```nickel
let Protocol = std.contract.any_of ['http, 'https, 'ftp] in
let SecureConfig = std.contract.all_of [
  { port | Number },
  std.contract.from_predicate (fun c => c.port != 80)
] in
```

______________________________________________________________________

## 4. Idiomatic Patterns (The "Pure" Nickel)

### 4.1 Match as a Function

In Nickel, a `match` block is a first-class function. Use it for mapping enum tags to values.

```nickel
let region_ami = match {
  'us-east-1 => "ami-123",
  'eu-central-1 => "ami-456",
} in

let config = {
  region = 'us-east-1,
  ami = region_ami region,
}
```

### 4.2 Pipeline Operator (`|>`)

Use the pipeline operator to keep deep transformations readable.

```nickel
let process = fun data =>
  data
  |> std.array.filter (fun x => x > 0)
  |> std.array.map (fun x => x * 2)
  |> std.array.fold_left (+) 0
```

### 4.3 Using `?` for Optional Defaults

The `?` operator is a concise way to handle optional fields with fallback values during merging.

```nickel
let make_config = fun opts => {
  port = opts.port ? 8080,
  host = opts.host ? "localhost",
}
```

______________________________________________________________________

## 5. Performance & Pitfalls

### 5.1 Avoiding Infinite Recursion

Nickel detects infinite recursion (e.g., `let x = x + 1`). Be careful when merging records that refer to themselves.

**Bad:**

```nickel
let rec conf = { a = 1, b = conf.a + 1 } in conf
```

**Better (using let-bindings):**

```nickel
let a = 1 in
{ a = a, b = a + 1 }
```

### 5.2 Lazy Evaluation Costs

While laziness is powerful, deeply nested merges or recursive contracts can impact evaluation time. For performance-critical sections, favor flat structures.

### 5.3 Serialization Limits

Remember that functions, unevaluated terms, and certain types (like some custom contracts that don't return a "plain" value) cannot be exported to JSON/YAML. Always verify with `nickel export`.

______________________________________________________________________

## 6. Comparison: Nickel vs. JSON-Schema-Generated Nickel

Generated code (like `json-schema-to-nickel`) often uses a functional "predicate" style which can be verbose and less performant.

**Generated Style (Verbose):**

```nickel
let MyType = predicates.contract_from_predicate (
  predicates.allOf [
    predicates.isType 'Record,
    predicates.records.required ["name"]
  ]
)
```

**Idiomatic Nickel Style (Clean):**

```nickel
let MyType = {
  name | String,
}
```

**Recommendation:** Use generated schemas for compatibility, but wrap them in idiomatic Nickel interfaces or write native Nickel contracts for new logic to leverage the full power of the language.

______________________________________________________________________

## 7. Tooling & Workflow

1. **`nickel format`**: Always format your code before committing.
1. **`nickel query`**: Use this to inspect types and documentation of fields in large configurations.
1. **`nickel repl`**: The best place to test complex contracts and functions.
1. **Doc Comments**: Use `| doc m%"..."%` to document your fields. It makes the configuration self-documenting for other developers (and LLMs).

For detailed documentation format, see [Nickel Interface Style Guide](nickel-interface-style.md#4-documentation-pattern).

______________________________________________________________________

## 8. Common Pitfalls for LLMs (Critical)

LLMs often confuse Nickel with Nix or older versions of Nickel. Pay attention to these:

### 8.1 Nickel vs. Nix Syntax

- **Merging**: Use `&` in Nickel. Nix uses `//`. Nickel's `&` is **recursive by default**.
- **Arrays**: Nickel uses `[1, 2, 3]`. Nix uses `[ 1 2 3 ]` (no commas). Comma is **REQUIRED** in Nickel.
- **Attributes**: Nickel uses `{ a = 1, b = 2 }`. Comma is **REQUIRED**.

### 8.2 The `rec` Keyword

- **`let rec`**: Needed for recursive functions.
- **Records**: Nickel records are NOT recursive by default for self-referencing fields.
  - `let conf = { a = 1, b = a + 1 }` -> **ERROR** (`a` is not in scope).
  - `let a = 1 in { a = a, b = a + 1 }` -> **CORRECT**.
  - **Self-referencing fields** in the same record usually require merging or separate let-bindings.

### 8.3 `std.` vs `builtin.`

- **NEVER** use `builtin.` in modern Nickel. The standard library is under the `std` namespace.
- **Always** use the full path: `std.string.uppercase`, not just `uppercase`.

### 8.4 Exporting Functions

- If you see `Error: function cannot be serialized`, it's because you are trying to `nickel export` a record that contains a function.
- Use the **Clean Export Pattern**: move functions to a `lib` record and export only the data fields.

______________________________________________________________________

## 9. References

- [Nickel Interface Style Guide](nickel-interface-style.md) - User interface design patterns
- [Nickel Module System](nickel-modules.md) - Module system architecture
