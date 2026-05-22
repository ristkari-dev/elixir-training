# Shared formatter config for the repo. Used:
#   1. When `mix format` runs from the repo root, it formats every lesson's
#      Elixir files via the recursive `lessons/**/` globs below.
#   2. As the source of truth for `line_length` and `locals_without_parens`;
#      lesson-level `.formatter.exs` files duplicate these values rather than
#      inheriting, because `.formatter.exs` files do not share configuration
#      in Mix (see `mix help format`).

[
  inputs: [
    "{mix,.formatter}.exs",
    "lessons/**/{mix,.formatter}.exs",
    "lessons/**/{config,lib,test}/**/*.{ex,exs}"
  ],
  line_length: 98,
  locals_without_parens: []
]
