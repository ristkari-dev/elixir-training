defmodule TrackerWeb.ProjectBoardLive do
  use TrackerWeb, :live_view

  alias Tracker.{Projects, Issues}

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    project = Projects.get_project!(String.to_integer(id))

    if project.user_id == socket.assigns.current_scope.user.id do
      {:ok, assign_board(socket, project)}
    else
      {:ok,
       socket
       |> put_flash(:error, "That project isn't yours.")
       |> redirect(to: ~p"/projects")}
    end
  end

  defp assign_board(socket, project) do
    socket
    |> assign(:project, project)
    |> assign(:issues, Issues.list_issues(project.id))
    |> assign(:form, to_form(Issues.change_issue(), as: :issue))
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>{@project.name} — board</.header>

      <.form for={@form} phx-submit="add_issue">
        <.input field={@form[:title]} label="New issue" />
        <.button>Add</.button>
      </.form>

      <ul id="issues">
        <li :for={issue <- @issues} id={"issue-#{issue.id}"}>
          <span class="title">{issue.title}</span>
          <span class="status">{issue.status}</span>
          <button phx-click="toggle" phx-value-id={issue.id}>Toggle</button>
        </li>
      </ul>
    </Layouts.app>
    """
  end

  @impl true
  def handle_event("add_issue", %{"issue" => params}, socket) do
    case Issues.create_issue(socket.assigns.project.id, params) do
      {:ok, _issue} ->
        {:noreply, assign_board(socket, socket.assigns.project)}

      {:error, changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset, as: :issue))}
    end
  end

  @impl true
  def handle_event("toggle", %{"id" => id}, socket) do
    Issues.toggle_issue(String.to_integer(id))
    {:noreply, assign(socket, :issues, Issues.list_issues(socket.assigns.project.id))}
  end
end
