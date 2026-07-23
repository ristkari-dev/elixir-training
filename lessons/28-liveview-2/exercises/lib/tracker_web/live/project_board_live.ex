defmodule TrackerWeb.ProjectBoardLive do
  use TrackerWeb, :live_view

  alias Tracker.{Projects, Issues}

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    project = Projects.get_project!(String.to_integer(id))

    if project.user_id == socket.assigns.current_scope.user.id do
      if connected?(socket), do: Phoenix.PubSub.subscribe(Tracker.PubSub, topic(project.id))

      {:ok,
       socket
       |> assign(:project, project)
       |> assign(:form, to_form(Issues.change_issue(), as: :issue))
       |> stream(:issues, Issues.list_issues(project.id))}
    else
      {:ok,
       socket
       |> put_flash(:error, "That project isn't yours.")
       |> redirect(to: ~p"/projects")}
    end
  end

  defp topic(project_id), do: "board:#{project_id}"

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>{@project.name} — board</.header>

      <.form for={@form} phx-submit="add_issue">
        <.input field={@form[:title]} label="New issue" />
        <.button>Add</.button>
      </.form>

      <ul id="issues" phx-update="stream">
        <li :for={{dom_id, issue} <- @streams.issues} id={dom_id}>
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
        # TODO: broadcast the new issue to other tabs with
        # Phoenix.PubSub.broadcast_from(Tracker.PubSub, self(), topic(...), {:issue, issue}),
        # and stream_insert it here so this tab shows it.
        {:noreply, assign(socket, :form, to_form(Issues.change_issue(), as: :issue))}

      {:error, changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset, as: :issue))}
    end
  end

  @impl true
  def handle_event("toggle", %{"id" => id}, socket) do
    Issues.toggle_issue(String.to_integer(id))
    # TODO: broadcast the toggled issue to other tabs and stream_insert it here
    # so the status updates live.
    {:noreply, socket}
  end

  @impl true
  def handle_info({:issue, _issue}, socket) do
    # TODO: stream_insert the issue so this tab updates when another tab changes it.
    {:noreply, socket}
  end
end
