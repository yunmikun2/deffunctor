defmodule Deffunctor do
  @moduledoc """
  `Deffunctor` provides a way to define module functors similar
  to [functors in OCaml](https://ocaml.org/learn/tutorials/functors.html).

  ## Usage

  Suppose we have a module that computes something:

      defmodule Doubler do
        def f(x), do: x * 2
      end

  And then we want to wrap this behaviour in some kind of logger.
  We define a functor that accomplishes just that:

      import Deffunctor

      deffunctor Logger.(module, printer) do
        def f(x) do
          result = module.f(x)
          printer.(result)
          result
        end
      end

  Now we can instantiate our `Doubler` that logs results:

      logging_doubler = Logger.new(Doubler, &IO.inspect/1)
      logging_doubler.f(2)

  And we can see that it prints the value, that's the same as the one
  returned from the function.
  """

  alias __MODULE__.Definition

  @doc """
  Create new functor.
  """
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
