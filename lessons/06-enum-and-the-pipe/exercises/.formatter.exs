# Self-contained formatter config for this lesson's Mix project. Mix does
# not share `.formatter.exs` between projects, so the style rules are
# duplicated here from the repo-root `.formatter.exs` (the source of truth).
# Update both files together if you change a rule.

[
  inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"],
  line_length: 98,
  locals_without_parens: []
]
