# main.ncl - Backends Main Configuration
#
# Entry point for backend-specific configurations.
{
  # Supported backend names
  backends = ["nsjail", "seatbelt", "hyperlight"],

  # Backend instance states
  states = ["created", "running", "stopped", "error"],
}
