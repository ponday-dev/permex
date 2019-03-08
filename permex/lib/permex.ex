defmodule Permex do
  alias Permex.Resolver.NoopResolver

  defmacro scope(key, resolver \\ NoopResolver, do: do_claus) do
    context = expand(key, do_claus)
    quote do
      permission unquote(key), unquote(resolver)

      unquote(context)
    end
  end

  def expand(key, {:__block__, _, lines}) do
    lines |> Enum.map(fn line -> expand(key, line) end)
  end
  def expand(key, {:permission, num, [permission_name | params]}) do
    child_permission = :"#{to_string(key)}_#{permission_name |> to_string()}"
    {:permission, num, [child_permission | params]}
  end
  def expand(_, line), do: line

  defmacro permission(key, resolver \\ NoopResolver)
  defmacro permission(key, resolver) when is_atom(key) do
      quote do
          def resolve(unquote(key), payload), do: apply(unquote(resolver), :perform, [payload])
      end
  end
  defmacro permission(_, _), do: nil

  defmacro __using__(_) do
      quote do
          require Permex
          import Permex, [warn: false]

          defmacro allow?(permissions, target, payload) do
              quote do
                  if Enum.member?(unquote(permissions), unquote(target)) do
                      apply(unquote(__MODULE__), :resolve, [unquote(target), unquote(payload)])
                  end
              end
          end

          defmacro allow?(permissions, target) when is_list(target) do
            quote do
              unquote(target)
              |> Enum.map(fn t ->
                if Keyword.keyword?(t) do
                  Enum.map(t, fn {key, payload} ->
                    unquote(__MODULE__).allow?(unquote(permissions), key, payload)
                  end)
                else
                  unquote(__MODULE__).allow?(unquote(permissions), t, nil)
                end
              end)
              |> Enum.flat_map(&(if is_list(&1), do: &1, else: [&1]))
              |> Enum.all?(&(&1))
            end
          end

          defmacro allow?(permissions, target) when is_atom(target) do
              quote do
                  unquote(__MODULE__).allow?(unquote(permissions), unquote(target), nil)
              end
          end
      end
  end
end
