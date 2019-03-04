defmodule Permex.Resolver.NoopResolver do
  @behaviour Permex.Resolver

  def perform(_), do: true
end
