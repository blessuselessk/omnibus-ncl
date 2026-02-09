# NCL Module System for Terraform

Organizing Terraform configurations with Nickel modules.

## Project Structure

```
terraform/
├── main.ncl           # Main entry point
├── variables.ncl      # Variable definitions
├── modules/
│   ├── vpc/
│   │   ├── main.ncl
│   │   ├── outputs.ncl
│   │   └── variables.ncl
│   └── ec2/
└── environments/
    ├── dev.ncl
    ├── staging.ncl
    └── prod.ncl
```

## Module Pattern

### main.ncl

```nickel
let Vpc = import "../modules/vpc/main.ncl" in
let Ec2 = import "../modules/ec2/main.ncl" in

{
  vpc = Vpc.default,
  ec2 = Ec2.default,
}
```

### Module Definition

```nickel
# modules/vpc/main.ncl
{
  default = {
    cidr = "10.0.0.0/16",
    public_subnets = ["10.0.1.0/24", "10.0.2.0/24"],
    private_subnets = ["10.0.101.0/24", "10.0.102.0/24"],
  },
}
```

## Environment Composition

```nickel
# environments/dev.ncl
let Base = import "../main.ncl" in

Base & {
  vpc.default.cidr = "10.1.0.0/16",
  instance_type = "t3.micro",
}
```
