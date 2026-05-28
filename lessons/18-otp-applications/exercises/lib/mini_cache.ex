defmodule MiniCache do
  @moduledoc "Public API for the supervised in-memory cache."

  @doc "Store value under key."
  def put(_key, _value), do: raise("TODO: delegate to MiniCache.Server.put/2")

  @doc "Fetch the value for key, or nil."
  def get(_key), do: raise("TODO: delegate to MiniCache.Server.get/1")

  @doc "Remove key from the cache."
  def delete(_key), do: raise("TODO: delegate to MiniCache.Server.delete/1")

  @doc "Return the number of entries."
  def size, do: raise("TODO: delegate to MiniCache.Server.size/0")
end
