defmodule TrackerWeb.ProjectController do
  use TrackerWeb, :controller

  def index(_conn, _params),
    do: raise(~s|TODO: render(conn, :index, projects: [a hard-coded list of project maps])|)
end
