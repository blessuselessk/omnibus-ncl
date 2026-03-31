# Terraform to Nickel Conversion

Converting Terraform HCL to Nickel format.

## Basic Conversion

### Terraform

```hcl
resource "aws_instance" "example" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t3.micro"

  tags = {
    Name        = "example"
    Environment = "dev"
  }
}
```

### Nickel

```nickel
{
  instance = {
    ami = "ami-0c55b159cbfafe1f0",
    instance_type = "t3.micro",
    tags = {
      Name = "example",
      Environment = "dev",
    },
  },
}
```

## Patterns

### Variables

**Terraform:**

```hcl
variable "region" {
  type    = string
  default = "us-east-1"
}
```

**Nickel:**

```nickel
let region | std.string.NonEmpty | default = "us-east-1" in
```

### Count/For Each

**Terraform:**

```hcl
resource "aws_instance" "servers" {
  count = 3
  # ...
}
```

**Nickel:**

```nickel
{
  servers = [
    { ami = "...", index = 0 },
    { ami = "...", index = 1 },
    { ami = "...", index = 2 },
  ],
}
```

### Modules

**Terraform:**

```hcl
module "vpc" {
  source  = "./vpc"
  version = "1.0.0"
}
```

**Nickel:**

```nickel
{
  vpc = import "./vpc/main.ncl",
}
```
