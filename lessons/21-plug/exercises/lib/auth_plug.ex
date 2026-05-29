defmodule AuthPlug do
  @moduledoc ~s|A module plug: halts with 401 unless the "x-token" header is "secret".|
  import Plug.Conn

  def init(opts), do: opts

  def call(_conn, _opts),
    do: raise(~s|TODO: pass the conn through if x-token is "secret", else send_resp 401 + halt|)
end
