# MutableEach

Implements imperative-style mutable iteration in Elixir.

In the spirit of https://github.com/wojtekmach/oop.

```elixir
use MutableEach

a = 1
b = 2
c = []
d = :ok

each item <- [1, 2, 3, 4, 5], mutable: {a, b, c} do
  d = :not_ok

  b = item

  a =
    if item == 2 do
      -1
    else
      a
    end

  if item == 3 do
    continue
  end

  if item == 4 do
    break
  end

  c = [item | c]
end

a #=> -1
b #=> 4
c #=> [2, 1]
d #=> :ok
```

This module uses `Enum.reduce_while/3`, `throw`, and macros to implement the
functionality. Under the hood, there is still no actual mutability. The
variables that are declared as "mutable" are simply provided as the accumulator
within `reduce_while`, automatically returned at the end of each iteration,
and then exported back into the original vars after the reduce is complete.

`continue` and `break` are implemented as macros which throw a tuple containing
an atom representing the type of interrupt (`continue` or `break`) and the
current values of the "mutable" variables. The function generated and passed to
`reduce_while` contains a catch clause that returns `{:cont, values}` or
`{:halt, values}` depending on the type of interrupt.

Just another great example of how powerful and flexible Elixir macros are.

## Installation

  1. Add `mutable_each` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:mutable_each, github: "antipax/mutable_each"}]
    end
    ```
