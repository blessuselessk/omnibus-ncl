# Message protocol contracts
#
# Models porkg's binary IPC protocol:
# - 5-byte header: 1 byte type tag + 4 bytes big-endian length
# - Body: MessagePack-serialized payload
# - Three message types: begin, start, quit
{
  ByteOrder
    | doc "Wire byte order for protocol headers"
    | not_exported
    = [| 'big_endian, 'little_endian |],

  MessageTag
    | doc "Protocol message type tag (maps to a single byte)"
    | not_exported
    = [| 'begin, 'start, 'quit |],

  MessageDef
    | doc m%"
      Definition of a protocol message type.

      Maps a tag to its payload schema and direction.

      # Examples

      ```nickel
      ({ tag = 'begin, direction = 'parent_to_worker, description = "Trigger privilege escalation" } | MessageDef)
      ```
    "%
    | not_exported
    = {
      tag
        | doc "Message type tag"
        | MessageTag,
      direction
        | doc "Which direction this message flows"
        | [| 'parent_to_worker, 'worker_to_job, 'job_to_worker, 'worker_to_parent, 'bidirectional |],
      description
        | doc "What this message does"
        | String,
      payload_fields
        | doc "Named fields in the MessagePack payload (empty for signal-only messages)"
        | Array String
        | default
        = [],
    },

  ProtoConfig
    | doc m%"
      Protocol configuration — byte order, max message size, buffer settings.

      # Examples

      ```nickel
      ({} | ProtoConfig)
      # => { byte_order = "big_endian", max_message_bytes = 4294967295, ... }
      ```
    "%
    | not_exported
    = {
      byte_order
        | doc "Wire byte order for headers"
        | ByteOrder
        | default
        = 'big_endian,
      max_message_bytes
        | doc "Maximum message body size (uint32 max by default)"
        | Number
        | default
        = 4294967295,
      buffer_reuse_threshold
        | doc "Buffer size threshold for reuse (bytes)"
        | Number
        | default
        = 1048576,
      serialization
        | doc "Serialization format"
        | [| 'msgpack |]
        | default
        = 'msgpack,
    },

  TagMap
    | doc m%"
      Bidirectional mapping between message types and wire tags.

      Defines the complete message vocabulary for a porkg process.
    "%
    | not_exported
    = {
      messages
        | doc "Ordered list of message definitions (index = wire tag byte)"
        | Array MessageDef,
      proto
        | doc "Protocol configuration"
        | ProtoConfig
        | default
        = {},
    },

  # -- porkg's default message set --

  default_messages
    | doc "porkg's three built-in message types"
    = [
      {
        tag = 'begin,
        direction = 'parent_to_worker,
        description = "Trigger privilege escalation to root",
      },
      {
        tag = 'start,
        direction = 'worker_to_job,
        description = "Spawn a new job subprocess",
      },
      {
        tag = 'quit,
        direction = 'bidirectional,
        description = "Graceful termination signal",
      },
    ],
}
