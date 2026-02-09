---
name: tf-ncl
description: Use when working with Terraform configurations through Nickel (tf-to-ncl), NCL-based Terraform modules, or tfsec security analysis.
metadata:
  author: omni-dev-fusion
  version: "1.0.0"
  source: "https://github.com/tao3k/omni-dev-fusion/tree/main/packages/ncl"
  routing_keywords:
    - "terraform"
    - "tf"
    - "tfsec"
    - "tf-to-ncl"
    - "infrastructure"
    - "IaC"
    - "terragrunt"
    - "aws"
    - "cloudformation"
---

# Terraform NCL Skill

Terraform configuration management through Nickel language integration and security scanning.

## Commands

| Command | Description |
|---------|-------------|
| [`tfsec_scan`](#tfsec_scan) | Scan Terraform for security issues |
| [`tf_to_ncl`](#tf_to_ncl) | Convert HCL to Nickel format |
| [`tf_validate`](#tf_validate) | Validate Terraform configurations |
| [`tf_plan`](#tf_plan) | Generate Terraform plan |

## Usage Examples

```python
# Scan infrastructure for security issues
@omni("tf-ncl.tfsec_scan", {"path": "infrastructure"})

# Convert Terraform to Nickel
@omni("tf-ncl.tf_to_ncl", {"tf_file": "main.tf", "output": "main.ncl"})

# Validate Terraform
@omni("tf-ncl.tf_validate", {"path": "infrastructure"})
```

## Concepts

| Topic | Description | Reference |
|-------|-------------|-----------|
| AWS Types | Nickel type contracts for AWS | [aws-types.md](references/aws-types.md) |
| tf-to-ncl | Conversion patterns | [conversion.md](references/conversion.md) |
| Module System | NCL module patterns | [module-system.md](references/module-system.md) |

## Best Practices

- Use NCL for multi-environment Terraform generation
- Run tfsec before deployment
- Define shared types for consistency

## Related Skills

| Topic | Description | Reference |
|-------|-------------|-----------|
| NCL Modules | Nickel module patterns | [nickel-modules.md](packages/ncl/nickel-modules.md) |
| Nix Integration | Nix shell for tfenv | [nix/nix.md](packages/ncl/nix/nix.md) |
