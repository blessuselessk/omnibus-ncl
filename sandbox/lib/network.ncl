# lib/network.ncl - Network policy configurations
#
# Pre-defined network policies for sandbox environments.
#
# Usage:
#   let network = import "lib/network.ncl" in
#   network.deny  # => deny network config

# ============================================
# Network Policy Records
# ============================================
{
  # No network access
  deny | doc m%"Network policy: no network access"% = {
    name | String = "deny",
    description | String = "No network access",
    clone_newnet | Bool = false,
    user_net | { _ : Dyn } = {},
    allowed_hosts | Array String = [],
  },

  # Localhost only
  localhost | doc m%"Network policy: localhost only"% = {
    name | String = "localhost",
    description | String = "Localhost only",
    clone_newnet | Bool = true,
    user_net = {
      enable | Bool = true,
      ipv4 | String = "10.0.0.1",
      ipv4_mask | Number = 24,
    },
    allowed_hosts | Array String = ["127.0.0.1", "localhost"],
  },

  # Loopback and container network
  container | doc m%"Network policy: container network"% = {
    name | String = "container",
    description | String = "Container network",
    clone_newnet | Bool = true,
    user_net = {
      enable | Bool = true,
      ipv4 | String = "10.0.0.1",
      ipv4_mask | Number = 24,
    },
    allowed_hosts | Array String = ["10.0.0.0/24"],
  },

  # Full network access
  allow | doc m%"Network policy: full network access"% = {
    name | String = "allow",
    description | String = "Full network access",
    clone_newnet | Bool = true,
    user_net | { _ : Dyn } = {},
    allowed_hosts | Array String = ["*"],
  },

  # Pre-built whitelists
  dev_api_whitelist | doc m%"Network policy: development API whitelist"% = {
    name | String = "whitelist",
    description | String = "Domain whitelist for development",
    clone_newnet | Bool = true,
    user_net = {
      enable | Bool = true,
      ipv4 | String = "10.0.0.1",
      ipv4_mask | Number = 24,
    },
    allowed_hosts | Array String = ["api.github.com", "localhost", "127.0.0.1"],
  },

  public_api_whitelist | doc m%"Network policy: public API whitelist"% = {
    name | String = "whitelist",
    description | String = "Domain whitelist for public APIs",
    clone_newnet | Bool = true,
    user_net = {
      enable | Bool = true,
      ipv4 | String = "10.0.0.1",
      ipv4_mask | Number = 24,
    },
    allowed_hosts | Array String = [
      "api.github.com",
      "api.bitbucket.org",
      "api.gitlab.com",
      "pypi.org",
      "files.pythonhosted.org",
    ],
  },

  data_whitelist | doc m%"Network policy: data API whitelist"% = {
    name | String = "whitelist",
    description | String = "Domain whitelist for data APIs",
    clone_newnet | Bool = true,
    user_net = {
      enable | Bool = true,
      ipv4 | String = "10.0.0.1",
      ipv4_mask | Number = 24,
    },
    allowed_hosts | Array String = ["api.example.com", "data.example.com"],
  },
}
