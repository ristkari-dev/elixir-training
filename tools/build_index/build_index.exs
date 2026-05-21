#!/usr/bin/env elixir
# tools/build_index/build_index.exs
#
# Produces a static slides site under dist/: every published lesson's slides
# copied into place, the vendored reveal.js assets copied alongside, and a
# generated index.html landing page listing all lessons grouped by phase.
#
# A lesson is "published" when its directory exists on disk AND contains a
# slides/ subdirectory. Lessons in the master list below that aren't on disk
# render as faded "future" placeholders.
#
# Usage:
#   elixir tools/build_index/build_index.exs           # uses defaults
#   elixir tools/build_index/build_index.exs --lessons lessons --shared shared/reveal --out dist

defmodule BuildIndex do
  @moduledoc false

  @phases [
    {0, "Programming-101 in Elixir"},
    {1, "Elixir core"},
    {2, "Concurrency & OTP"},
    {3, "Phoenix"},
    {4, "Ecto deep dive"},
    {5, "Production"},
    {6, "Capstone"}
  ]

  # Master list of all 41 lessons. Editing this list is how a new lesson
  # appears on the landing page (initially as a faded placeholder; it lights
  # up once the matching lessons/NN-slug/slides/ directory lands on disk).
  @all_lessons [
    # Phase 0 — Programming-101 in Elixir
    {"00", "setup", "Setup", "asdf · iex · mix new", 0},
    {"01", "values-and-types", "Values & types", "integers · atoms · strings", 0},
    {"02", "pattern-matching", "Pattern matching", "= as match · destructuring", 0},
    {"03", "functions-and-modules", "Functions & modules", "def · arity · guards", 0},
    {"04", "control-flow", "Control flow", "case · cond · with", 0},

    # Phase 1 — Elixir core
    {"05", "recursion", "Recursion", "head/tail · no for loops", 1},
    {"06", "enum-and-the-pipe", "Enum & the pipe", "Enum · |> · composition", 1},
    {"07", "collections", "Collections", "lists · maps · tuples · keywords", 1},
    {"08", "strings-and-binaries", "Strings & binaries", "sigils · binary pattern matching", 1},
    {"09", "streams", "Streams", "lazy enumeration", 1},
    {"10", "structs-and-protocols", "Structs & protocols", "defstruct · defprotocol", 1},
    {"11", "error-handling", "Error handling", "{:ok, _} · raise · with", 1},
    {"12", "mix-projects", "Mix projects", "mix new · deps · ExUnit", 1},

    # Phase 2 — Concurrency & OTP
    {"13", "processes", "Processes", "spawn · send · receive", 2},
    {"14", "tasks-and-agents", "Tasks & Agents", "lightweight concurrency", 2},
    {"15", "genserver-1", "GenServer I", "call · cast · init", 2},
    {"16", "genserver-2", "GenServer II", "handle_info · testing", 2},
    {"17", "supervisors", "Supervisors", "restart strategies · trees", 2},
    {"18", "otp-applications", "OTP applications", "application callback · config", 2},
    {"19", "ets", "ETS", "fast in-memory storage", 2},
    {"20", "distribution", "Distribution", ":rpc · libcluster · nodes", 2},

    # Phase 3 — Phoenix
    {"21", "plug", "Plug", "Plug.Conn · the pipeline", 3},
    {"22", "phoenix-tour", "Phoenix tour", "mix phx.new · project tour", 3},
    {"23", "controllers-and-heex", "Controllers & HEEx", "actions · HEEx · layouts", 3},
    {"24", "forms-and-changesets-preview", "Forms & changesets preview", "render a form · validate", 3},
    {"25", "contexts", "Contexts", "the context pattern", 3},
    {"26", "auth", "Authentication", "phx.gen.auth · sessions", 3},
    {"27", "liveview-1", "LiveView I", "mount · render · handle_event", 3},
    {"28", "liveview-2", "LiveView II", "streams · PubSub · components", 3},

    # Phase 4 — Ecto deep dive
    {"29", "schemas-and-migrations", "Schemas & migrations", "schema · field · migrate", 4},
    {"30", "changesets-deep", "Changesets deep dive", "cast · validations · constraints", 4},
    {"31", "queries", "Queries", "joins · preloads · dynamic", 4},
    {"32", "associations", "Associations", "has_many · belongs_to · m:n", 4},
    {"33", "multi-and-transactions", "Multi & transactions", "Ecto.Multi · rollback", 4},

    # Phase 5 — Production
    {"34", "testing", "Testing", "ConnCase · DataCase · LiveViewTest", 5},
    {"35", "observability", "Observability", ":telemetry · LiveDashboard", 5},
    {"36", "background-jobs", "Background jobs", "Oban · workers · cron", 5},
    {"37", "releases-and-docker", "Releases & Docker", "mix release · Dockerfile", 5},
    {"38", "fly-deploy", "Fly deploy", "flyctl · Postgres add-on", 5},

    # Phase 6 — Capstone
    {"39", "capstone-build", "Capstone build", "final feature work", 6},
    {"40", "capstone-ship", "Capstone ship", "deploy · smoke test · retro", 6}
  ]

  def run(argv) do
    {opts, _, _} =
      OptionParser.parse(argv,
        strict: [lessons: :string, shared: :string, out: :string]
      )

    lessons_dir = Keyword.get(opts, :lessons, "lessons")
    shared_dir = Keyword.get(opts, :shared, "shared/reveal")
    out_dir = Keyword.get(opts, :out, "dist")
    template = Path.join(__DIR__, "index.html.eex")

    build(lessons_dir, shared_dir, out_dir, template)
    IO.puts("built #{out_dir}")
  end

  def build(lessons_dir, shared_dir, out_dir, template) do
    File.rm_rf!(out_dir)
    File.mkdir_p!(out_dir)

    phases = build_phases(lessons_dir)

    # Copy every published lesson's slides
    Enum.each(phases, fn phase ->
      Enum.each(phase.lessons, fn lesson ->
        if lesson.published do
          src = Path.join([lessons_dir, lesson.name, "slides"])
          dst = Path.join([out_dir, "lessons", lesson.name, "slides"])
          File.mkdir_p!(Path.dirname(dst))
          File.cp_r!(src, dst)
        end
      end)
    end)

    # Copy shared/reveal
    if File.dir?(shared_dir) do
      File.mkdir_p!(Path.join(out_dir, "shared"))
      File.cp_r!(shared_dir, Path.join([out_dir, "shared", "reveal"]))
    end

    # Render index.html
    html = render_index(template, phases)
    File.write!(Path.join(out_dir, "index.html"), html)
  end

  defp build_phases(lessons_dir) do
    published = collect_published(lessons_dir)

    by_phase =
      Enum.group_by(@all_lessons, fn {_n, _s, _t, _b, phase} -> phase end)

    Enum.map(@phases, fn {num, name} ->
      lessons =
        (by_phase[num] || [])
        |> Enum.sort_by(fn {n, _s, _t, _b, _p} -> n end)
        |> Enum.map(fn {number, slug, title, blurb, _phase} ->
          lesson_name = number <> "-" <> slug

          %{
            number: number,
            title: title,
            blurb: blurb,
            name: lesson_name,
            published: MapSet.member?(published, lesson_name)
          }
        end)

      %{number: num, name: name, lessons: lessons}
    end)
  end

  defp collect_published(lessons_dir) do
    case File.ls(lessons_dir) do
      {:ok, entries} ->
        entries
        |> Enum.filter(fn name ->
          path = Path.join(lessons_dir, name)
          File.dir?(path) and File.dir?(Path.join(path, "slides"))
        end)
        |> MapSet.new()

      {:error, _} ->
        MapSet.new()
    end
  end

  defp render_index(template_path, phases) do
    EEx.eval_file(template_path, assigns: [phases: phases])
  end
end

BuildIndex.run(System.argv())
