# Skip `@tag :pending` tests by default. The exercise tests carry this tag
# until the learner makes them pass — run `mix test --include pending` to
# see what the exercise is asking for. Solutions do NOT skip pending.
ExUnit.start(exclude: [pending: true])
