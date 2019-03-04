defmodule Permex.Resolver do
  @callback perform(payload :: term) :: boolean
end
