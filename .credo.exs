# Shared Credo config. Activated by lessons from lesson 34 onward.
%{
  configs: [
    %{
      name: "default",
      files: %{
        included: ["lib/", "src/", "test/", "web/", "apps/"],
        excluded: [~r"/_build/", ~r"/deps/", ~r"/node_modules/"]
      },
      strict: false,
      checks: %{
        enabled: [
          {Credo.Check.Readability.ModuleDoc, false},
          {Credo.Check.Design.TagTODO, false}
        ]
      }
    }
  ]
}
