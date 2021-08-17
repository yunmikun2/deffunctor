defmodule Deffunctor do
  @moduledoc false

  alias __MODULE__.Definition

  defmacro deffunctor(prototype, do: body) do
    definition = Definition.decompose(prototype, __CALLER__)
    %Definition{name: module, attrs: attrs} = definition

    quote location: :keep do
      defmodule unquote(module) do
        def new(unquote_splicing(attrs)) do
          body =
            Definition.replace_attrs(
              unquote(Macro.escape(definition)),
              unquote(Macro.escape(body)),
              unquote(attrs)
            )

          module_name =
            Definition.functor_instance_module(
              unquote(module),
              unquote(attrs)
            )

          case Code.ensure_compiled(module_name) do
            {:module, module} ->
              module

            {:error, _} ->
              module_ast = Definition.wrap_body_in_module(module_name, body)
              [{module, _bytecode}] = Code.compile_quoted(module_ast)
              module
          end
        end
      end
    end
  end
end
