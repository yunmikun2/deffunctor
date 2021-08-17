defmodule DeffunctorTest do
  use ExUnit.Case

  describe "deffunctor/2" do
    test "creates a functor for a module" do
      defmodule X do
        def f(x), do: x + 1
      end

      import Deffunctor

      deffunctor Multiplier.(module, n) do
        def f(x), do: module.f(x) * n
      end

      module = Multiplier.new(X, 2)
      assert module.f(1) == 4
    end

    test "doesn't redefine the module" do
      defmodule Y do
        def f(x), do: x + 1
      end

      import Deffunctor

      deffunctor Wrapper.(module) do
        def f(x), do: module.f(x) * 2
      end

      Wrapper.new(Y)
      Wrapper.new(Y)
    end
  end
end
