defmodule ApiRouter do
  @moduledoc "A Plug.Router composing the plugs into a pipeline."
  use Plug.Router

  plug(:match)
  plug(:dispatch)

  get("/hello", do: raise(~s|TODO: send_resp(conn, 200, "hello")|))

  get "/secret" do
    _ = conn
    raise(~s|TODO: run AuthPlug; if halted return conn, else send_resp(conn, 200, "top secret")|)
  end
end
