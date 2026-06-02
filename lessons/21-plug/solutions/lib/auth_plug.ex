defmodule AuthPlug do
  @moduledoc ~s|A module plug: halts with 401 unless the "x-token" header is "secret".|
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    case get_req_header(conn, "x-token") do
      ["secret"] -> conn
      _ -> conn |> send_resp(401, "unauthorized") |> halt()
    end
  end
end
