# Export the protocol tag map — message definitions and wire format
# Usage: nickel export --format json porkg-ncl/examples/proto-export.ncl
let { TagMap, default_messages, .. } = import "../lib/proto.ncl" in

{ messages = default_messages } | TagMap
