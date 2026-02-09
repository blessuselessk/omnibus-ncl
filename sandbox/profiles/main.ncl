# profiles/main.ncl - Profiles Main Export
#
# Aggregates all security profiles.
{
  base = import "base.ncl",
  relaxed = import "relaxed.ncl",
  standard = import "standard.ncl",
  strict = import "strict.ncl",
}
