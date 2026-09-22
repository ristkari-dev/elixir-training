defmodule TrackerWeb.PageController do
  use TrackerWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end

  def ping(conn, _params), do: text(conn, "pong")
end
