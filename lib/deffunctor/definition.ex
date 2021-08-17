defmodule Deffunctor.Definition do
  @moduledoc false

  defstruct [:name, :attrs]

  def decompose(prototype, env) do
    case prototype do
      {{:., _, [{:__aliases__, [alias: _], _}]}, _, []} ->
        raise ArgumentError, "functor must have at least one attribute"

      {{:., _, [{:__aliases__, alias_meta, components}]}, _, attrs} ->
        module_name =
          case Keyword.fetch(alias_meta, :alias) do
            {:ok, module} when is_atom(module) and module != false -> module
            _ -> Module.concat(components)
          end

        %__MODULE__{name: module_name, attrs: attrs}

      _ ->
        raise SyntaxError,
          line: env.line,
          description: "invalid functor signature",
          file: env.file
    end
  end

  def replace_attrs(%__MODULE__{attrs: attr_keys}, body, attr_values) do
    attrs_map =
      attr_keys
      |> Enum.map(fn {f, _, a} -> {f, a} end)
      |> Enum.zip(attr_values)
      |> Enum.into(%{})

    Macro.prewalk(body, fn
      {f, _, a} = node ->
        key = {f, a}

        case attrs_map do
          %{^key => value} -> value
          _ -> node
        end

      node ->
        node
    end)
  end

  def wrap_body_in_module(module, attrs, body) do
    quote do
      defmodule unquote(Module.concat(module, functor_instance_suffix(attrs))) do
        unquote(body)
      end
    end
  end

  defp functor_instance_suffix(attrs) do
    binary = :erlang.term_to_binary(attrs)
    hash = :crypto.hash(:sha3_224, binary)
    "Instance#{Base.encode16(hash)}"
  end
end
