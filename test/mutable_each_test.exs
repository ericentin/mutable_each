defmodule MutableEachTest do
  use ExUnit.Case
  import MutableEach

  test "each" do
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

    assert a == -1
    assert b == 4
    assert c == [2, 1]
    assert d == :ok
  end

  test "each matching" do
    a = 1

    each {:ok, item} <- [{:ok, 1}, {:ok, 2}, {:ok, 3}],
      mutable: {a},
      do: a = item

    assert a == 3
  end
end
