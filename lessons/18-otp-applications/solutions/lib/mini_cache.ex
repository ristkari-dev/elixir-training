defmodule MiniCache do
  @moduledoc "Public API for the supervised in-memory cache."
  alias MiniCache.Server

  defdelegate put(key, value), to: Server
  defdelegate get(key), to: Server
  defdelegate delete(key), to: Server
  defdelegate size, to: Server
end
