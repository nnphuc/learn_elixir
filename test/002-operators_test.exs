ExUnit.start()

defmodule OperatorsTest do
  use ExUnit.Case, async: true

  # =============================================================
  # 002 - Operators
  # Elixir provides arithmetic, comparison, boolean, and
  # string operators.
  # =============================================================

  describe "arithmetic operators" do
    test "basic math" do
      assert 1 + 2 == 3
      assert 5 - 3 == 2
      assert 3 * 4 == 12
    end

    test "division always returns a float" do
      assert 10 / 2 == 5.0
      assert is_float(10 / 2)
    end

    test "integer division and remainder" do
      assert div(10, 3) == 3
      assert rem(10, 3) == 1
    end

    test "remainder keeps the sign of the dividend" do
      assert rem(-10, 3) == -1
      assert rem(10, -3) == 1
    end
  end

  describe "comparison operators" do
    test "equality and inequality" do
      assert 1 == 1
      assert 1 != 2
    end

    test "strict equality distinguishes integers and floats" do
      assert 1 == 1.0       # value equality
      assert 1 !== 1.0      # strict: different types
      assert 1 === 1        # strict: same type and value
    end

    test "ordering" do
      assert 1 < 2
      assert 2 > 1
      assert 1 <= 1
      assert 2 >= 1
    end

    test "any two types can be compared (type ordering)" do
      # number < atom < reference < function < port < pid < tuple < map < list < bitstring
      assert 1 < :atom
      assert :atom < "string"
    end
  end

  describe "boolean operators (strict)" do
    # and, or, not expect a boolean as first argument

    test "and" do
      assert true and true
      refute true and false
      refute false and true
    end

    test "or" do
      assert true or false
      assert false or true
      refute false or false
    end

    test "not" do
      assert not false
      refute not true
    end

    test "and/or are short-circuit operators" do
      # The second argument is only evaluated if needed
      assert true or raise("this won't be evaluated")
      refute false and raise("this won't be evaluated")
    end
  end

  describe "boolean operators (relaxed: ||, &&, !)" do
    # ||, &&, ! accept any type. Everything except false and nil is truthy.

    test "truthy and falsy values" do
      # nil and false are falsy, everything else is truthy
      assert !nil
      assert !false
      refute !1
      refute !"hello"
      refute ![]
    end

    test "&& returns first falsy or last truthy" do
      assert (1 && 2) == 2
      assert (1 && nil) == nil
      assert (nil && 2) == nil
    end

    test "|| returns first truthy or last falsy" do
      assert (1 || 2) == 1
      assert (nil || 2) == 2
      assert (false || nil) == nil
    end
  end

  describe "string operators" do
    test "concatenation with <>" do
      assert "hello" <> " " <> "world" == "hello world"
    end

    test "interpolation with #{}" do
      x = 42
      assert "value: #{x}" == "value: 42"
    end
  end

  describe "list operators" do
    test "concatenation with ++" do
      assert [1, 2] ++ [3, 4] == [1, 2, 3, 4]
    end

    test "subtraction with --" do
      assert [1, 2, 3, 4] -- [2, 4] == [1, 3]
    end

    test "subtraction removes first occurrence only" do
      assert [1, 2, 2, 3] -- [2] == [1, 2, 3]
    end
  end

  describe "the in operator" do
    test "checks membership in a list or range" do
      assert 1 in [1, 2, 3]
      refute 4 in [1, 2, 3]
      assert 5 in 1..10
    end
  end
end
