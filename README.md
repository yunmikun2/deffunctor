# Deffunctor

`Deffunctor` provides a way to define module functors similar
to [functors in OCaml](https://ocaml.org/learn/tutorials/functors.html).

## Usage

Suppose we have a module that computes something:

```elixir
defmodule Doubler do
  def f(x), do: x * 2
end
```

And then we want to wrap this behaviour in some kind of logger.
We define a functor that accomplishes just that:

```elixir
import Deffunctor

deffunctor Logger.(module, printer) do
  def f(x) do
    result = module.f(x)
    printer.(result)
    result
  end
end
```

Now we can instantiate our `Doubler` that logs results:

```elixir
logging_doubler = Logger.new(Doubler, &IO.inspect/1)
logging_doubler.f(2)
```

And we can see that it prints the value, that's the same as the one
returned from the function.

## Installation

Add `deffunctor` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:deffunctor, git: "https://github.com/yunmikun2/deffunctor"}
  ]
end
```
