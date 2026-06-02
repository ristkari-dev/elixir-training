defmodule Greeter do
  @moduledoc "A function plug: sets a response header on the conn."
  import Plug.Conn

  def init(opts), do: opts

  def call(_conn, _opts), do: raise(~s|TODO: put_resp_header(conn, "x-greeting", "hello")|)
end
