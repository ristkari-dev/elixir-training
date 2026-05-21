# Shared formatter config for every lesson's Mix project.
# Lesson formatter files do `import_deps: [:phoenix, :phoenix_live_view]` etc.
# as needed and `import_config "../../../.formatter.exs"` to inherit these.

[
  inputs: [
    "{mix,.formatter}.exs",
    "{config,lib,test}/**/*.{ex,exs}"
  ],
  line_length: 98,
  locals_without_parens: []
]
