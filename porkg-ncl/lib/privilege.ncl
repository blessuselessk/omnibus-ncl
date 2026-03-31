# Privilege escalation model
#
# porkg implements controlled privilege escalation through its
# process hierarchy. The "begin" message triggers escalation.
# This contract models the privilege levels and escalation rules.
{
  PrivilegeLevel
    | doc "Process privilege level in the hierarchy"
    | not_exported
    = [| 'unprivileged, 'user, 'elevated, 'root |],

  EscalationRule
    | doc m%"
      Rule governing privilege escalation between process levels.

      # Examples

      ```nickel
      ({
        from = 'user,
        to = 'root,
        trigger = 'begin,
        requires_user_namespace = true,
      } | EscalationRule)
      ```
    "%
    | not_exported
    = {
      from
        | doc "Source privilege level"
        | PrivilegeLevel,
      to
        | doc "Target privilege level"
        | PrivilegeLevel,
      trigger
        | doc "Message that triggers this escalation"
        | [| 'begin, 'explicit |],
      requires_user_namespace
        | doc "Whether user namespace isolation is required"
        | Bool
        | default
        = true,
    },

  PrivilegeConfig
    | doc m%"
      Privilege configuration for a porkg process hierarchy.

      Defines the initial privilege level and allowed escalation rules.
    "%
    | not_exported
    = {
      initial_level
        | doc "Privilege level at process start"
        | PrivilegeLevel
        | default
        = 'user,
      allow_escalation
        | doc "Whether privilege escalation is permitted"
        | Bool
        | default
        = true,
      rules
        | doc "Escalation rules"
        | Array EscalationRule
        | default
        = [
          {
            from = 'user,
            to = 'root,
            trigger = 'begin,
            requires_user_namespace = true,
          },
        ],
    },
}
