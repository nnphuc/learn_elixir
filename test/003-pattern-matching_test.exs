ExUnit.start()

defmodule PatternMatchingTest do
  use ExUnit.Case, async: true

  # =============================================================
  # 003 - Pattern Matching
  # In Elixir, the = operator is the match operator.
  # It's used to match and bind values, not just assign them.
  # =============================================================

  describe "the match operator =" do
    test "basic matching (looks like assignment)" do
      x = 1
      assert x == 1
    end

    test "matching on the left side" do
      # The left side is a pattern, the right side is a value
      {a, b, c} = {1, 2, 3}
      assert a == 1
      assert b == 2
      assert c == 3
    end

    test "match error when sides don't match" do
      assert_raise MatchError, fn ->
        {a, b} = {1, 2, 3}
        # suppress unused variable warning
        {a, b}
      end
    end

    test "matching specific values" do
      {:ok, result} = {:ok, 42}
      assert result == 42
    end

    test "match error on value mismatch" do
      assert_raise MatchError, fn ->
        {:ok, _result} = {:error, "something went wrong"}
      end
    end
  end

  describe "matching with lists" do
    test "match a whole list" do
      [a, b, c] = [1, 2, 3]
      assert a == 1
      assert b == 2
      assert c == 3
    end

    test "head and tail with |" do
      [head | tail] = [1, 2, 3, 4]
      assert head == 1
      assert tail == [2, 3, 4]
    end

    test "head and tail with single element list" do
      [head | tail] = [1]
      assert head == 1
      assert tail == []
    end

    test "match first few elements" do
      [first, second | rest] = [1, 2, 3, 4, 5]
      assert first == 1
      assert second == 2
      assert rest == [3, 4, 5]
    end
  end

  describe "the underscore _ (ignore)" do
    test "underscore matches anything and discards the value" do
      {_, b, _} = {1, 2, 3}
      assert b == 2
    end

    test "underscore cannot be read" do
      # _ is special - you can't read from it
      _ = 42
      assert_raise CompileError, fn ->
        Code.eval_string("_ = 42; _")
      end
    end

    test "variables starting with _ are bound but warn if unused" do
      {_ignored, value} = {:not_needed, 42}
      assert value == 42
      # _ignored is bound but conventionally not used
    end
  end

  describe "the pin operator ^" do
    test "pin prevents rebinding, forces a match" do
      x = 1
      # Without pin, x would be rebound
      # With pin, it matches against the current value of x
      ^x = 1  # matches because x is 1
      assert x == 1
    end

    test "pin raises on mismatch" do
      x = 1
      assert_raise MatchError, fn ->
        ^x = 2  # fails because x is 1, not 2
      end
    end

    test "pin in a tuple" do
      x = 1
      {^x, y} = {1, 2}
      assert y == 2
    end

    test "pin in function heads (via case)" do
      expected = "hello"

      result = case "hello" do
        ^expected -> "matched!"
        _ -> "didn't match"
      end

      assert result == "matched!"
    end
  end

  describe "matching maps" do
    test "match specific keys" do
      %{name: name} = %{name: "Alice", age: 30}
      assert name == "Alice"
    end

    test "map patterns match subsets" do
      # You don't need to match all keys
      %{age: age} = %{name: "Alice", age: 30, city: "NYC"}
      assert age == 30
    end

    test "empty map matches any map" do
      %{} = %{name: "Alice", age: 30}
      # No error - empty map pattern matches any map
    end
  end

  describe "matching strings" do
    test "match string prefix with <>" do
      "hello " <> rest = "hello world"
      assert rest == "world"
    end

    test "match error if prefix doesn't match" do
      assert_raise MatchError, fn ->
        "goodbye " <> _rest = "hello world"
      end
    end
  end
end
