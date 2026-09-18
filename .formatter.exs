# Shared formatter config for the repo root. Used:
#   1. To format the repo root's own files (this file, mix.exs if any) via
#      `mix format`. It does NOT reach into `lessons/**` — each lesson formats
#      itself through its own `.formatter.exs` (see `tools/lint-all`), because
#      this root config's `locals_without_parens: []` would otherwise force
#      parentheses onto every lesson's Phoenix/Ecto DSL calls.
#   2. As the source of truth for `line_length` and `locals_without_parens`;
#      lesson-level `.formatter.exs` files duplicate these values rather than
#      inheriting, because `.formatter.exs` files do not share configuration
#      in Mix (see `mix help format`).

[
  inputs: [
    "{mix,.formatter}.exs"
  ],
  line_length: 98,
  locals_without_parens: []
]
