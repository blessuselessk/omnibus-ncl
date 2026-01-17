let Aws = import "./types.ncl" in
{
  aws.state
    | {
      bucket = "my-terraform-state-bucket",
      key = "terraform/state",
      region = 'us-west-2,
    },
  config.terraform.backend.s3 = {
    bucket = aws.state.bucket,
    key = aws.state.key,
    region = std.string.from aws.state.region,
  },
}

