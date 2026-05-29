defmodule ApiRouter do
  @moduledoc "A Plug.Router composing the plugs into a pipeline."
  use Plug.Router

  plug(:match)
  plug(:dispatch)

  get("/hello", do: send_resp(conn, 200, "hello"))

  get "/secret" do
    conn = AuthPlug.call(conn, AuthPlug.init([]))
    if conn.halted, do: conn, else: send_resp(conn, 200, "top secret")
  end
end
