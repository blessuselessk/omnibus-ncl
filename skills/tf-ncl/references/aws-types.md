# AWS Types Reference

Nickel type contracts for AWS resource validation.

## Region Type

```nickel
let Aws = import "../../aws/types.ncl" in

{ region | Aws.Region = "us-east-1" }
```

Valid regions:
- `us-east-1`, `us-west-1`, `us-west-2`
- `eu-west-1`, `eu-central-1`
- `ap-southeast-1`, `ap-northeast-1`

## Instance Type

```nickel
{ instance_type | Aws.InstanceType = "t3.micro" }
```

Instance families: t3, t2, m5, c5, r5, i3, d2

## Tags Type

```nickel
let Aws = import "../../aws/types.ncl" in

{
  tags | Aws.Tags = {
    Name = "my-instance",
    Environment = "dev",
    Project = "omni",
  },
}
```

## Complete Example

```nickel
let Aws = import "../../aws/types.ncl" in

{
  name | std.string.NonEmpty,
  region | Aws.Region,
  instance_type | Aws.InstanceType,
  tags | Aws.Tags = {},
}
```
