defmodule TrackerWeb.PageController do
  use TrackerWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end

  def ping(_conn, _params), do: raise(~s|TODO: text(conn, "pong")|)
end
