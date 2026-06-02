defmodule Greeter do
  @moduledoc "A function plug: sets a response header on the conn."
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts), do: put_resp_header(conn, "x-greeting", "hello")
end
