defmodule MutableEach do
  @moduledoc """
  Implements imperative-style mutable iteration:

      a = 1
      b = 2
      c = []
      d = :ok

      each item <- [1, 2, 3, 4, 5], mutable: [a, b, c] do
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
  """

  defmacro each(item_enumerable, [mutable: mutable, do: do_clause]) do
    do_each(item_enumerable, mutable, do_clause)
  end

  defmacro each(item_enumerable, [mutable: mutable], [do: do_clause]) do
    do_each(item_enumerable, mutable, do_clause)
  end

  defmacro continue do
    quote do
      {mutable_var_values, _} =
        Code.eval_quoted(var!(mutable_vars, __MODULE__), binding(), __ENV__)

      throw {:mutable_each_continue, mutable_var_values}
    end
  end

  defmacro break do
    quote do
      {mutable_var_values, _} =
        Code.eval_quoted(var!(mutable_vars, __MODULE__), binding(), __ENV__)

      throw {:mutable_each_break, mutable_var_values}
    end
  end

  defp do_each({:<-, _, [item, enumerable]}, mutable, do_clause) do
    mutable_vars = quote do: {unquote_splicing(mutable)}

    quote do
      var!(mutable_vars, __MODULE__) = unquote(Macro.escape(mutable_vars))

      fun =
        fn unquote(item), unquote(mutable_vars) ->
          import MutableEach, only: [continue: 0, break: 0]

          try do
            # Suppress unused var warnings for mutable vars
            _ = unquote(mutable_vars)

            unquote(do_clause)
            {:cont, unquote(mutable_vars)}
          catch
            {:mutable_each_continue, mutable} -> {:cont, mutable}
            {:mutable_each_break, mutable} -> {:halt, mutable}
          end
        end

      unquote(mutable_vars) =
        Enum.reduce_while(unquote(enumerable), unquote(mutable_vars), fun)

      :ok
    end
  end
end
