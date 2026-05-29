defmodule TrackerWeb.ProjectController do
  use TrackerWeb, :controller

  alias Tracker.ProjectStore

  @types %{name: :string, status: :string}

  def index(conn, _params), do: render(conn, :index, projects: ProjectStore.list())

  def new(_conn, _params),
    do:
      raise(
        ~s|TODO: render(conn, :new, form: to_form of an empty change/0 changeset, as: :project)|
      )

  def create(_conn, _params),
    do:
      raise(
        ~s|TODO: validate params; if valid add to ProjectStore + flash + redirect, else re-render :new|
      )

  # Provided helper: a schemaless changeset (no DB schema needed).
  defp change(attrs \\ %{}) do
    {%{status: "open"}, @types}
    |> Ecto.Changeset.cast(attrs, Map.keys(@types))
    |> Ecto.Changeset.validate_required([:name])
  end

  # Provided so `change/1` (and its default) aren't flagged unused while
  # new/2 and create/2 are still TODO stubs. Delete once you've wired them up.
  @doc false
  def __change__, do: change()
end
