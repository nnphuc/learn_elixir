ExUnit.start()

defmodule ControlFlowTest do
  use ExUnit.Case, async: true

  # =============================================================
  # 007 - Control Flow
  # Elixir prefers pattern matching over traditional control flow,
  # but provides if/else, case, cond, and with.
  # =============================================================

  describe "if and unless" do
    test "if with truthy value" do
      result = if true, do: "yes", else: "no"
      assert result == "yes"
    end

    test "if with falsy value" do
      result = if nil, do: "yes", else: "no"
      assert result == "no"
    end

    test "if returns nil when no else and condition is falsy" do
      result = if false, do: "yes"
      assert result == nil
    end

    test "unless is the opposite of if" do
      result = unless false, do: "yes", else: "no"
      assert result == "yes"
    end

    test "block syntax" do
      result = if 1 + 1 == 2 do
        "math works"
      else
        "math is broken"
      end
      assert result == "math works"
    end

    test "only false and nil are falsy" do
      assert if(0, do: true)       # 0 is truthy
      assert if("", do: true)      # empty string is truthy
      assert if([], do: true)      # empty list is truthy
      refute if(false, do: true)   # false is falsy
      refute if(nil, do: true)     # nil is falsy
    end
  end

  describe "case" do
    test "case matches against patterns" do
      result = case {1, 2, 3} do
        {4, 5, 6} -> "no match"
        {1, x, 3} -> "matched with x = #{x}"
        _ -> "catch all"
      end
      assert result == "matched with x = 2"
    end

    test "case with guards" do
      check_number = fn n ->
        case n do
          x when x < 0 -> "negative"
          0 -> "zero"
          x when x > 0 -> "positive"
        end
      end

      assert check_number.(-5) == "negative"
      assert check_number.(0) == "zero"
      assert check_number.(10) == "positive"
    end

    test "case raises when no clause matches" do
      assert_raise CaseClauseError, fn ->
        case :hello do
          :world -> "nope"
        end
      end
    end

    test "case with pin operator" do
      expected = 42
      result = case {1, 42} do
        {_, ^expected} -> "found it"
        _ -> "not found"
      end
      assert result == "found it"
    end

    test "common pattern: matching ok/error tuples" do
      handle_result = fn result ->
        case result do
          {:ok, value} -> "Success: #{value}"
          {:error, reason} -> "Error: #{reason}"
        end
      end

      assert handle_result.({:ok, "data"}) == "Success: data"
      assert handle_result.({:error, "timeout"}) == "Error: timeout"
    end
  end

  describe "cond" do
    test "cond evaluates conditions until one is true" do
      temperature = 35

      weather = cond do
        temperature > 40 -> "extremely hot"
        temperature > 30 -> "hot"
        temperature > 20 -> "warm"
        temperature > 10 -> "cool"
        true -> "cold"
      end

      assert weather == "hot"
    end

    test "cond with a catch-all true clause" do
      result = cond do
        2 + 2 == 5 -> "math is wrong"
        1 + 1 == 3 -> "still wrong"
        true -> "fallback"
      end
      assert result == "fallback"
    end

    test "cond raises when no condition matches" do
      assert_raise CondClauseError, fn ->
        cond do
          false -> "nope"
          nil -> "nope"
        end
      end
    end

    test "fizzbuzz with cond" do
      fizzbuzz = fn n ->
        cond do
          rem(n, 15) == 0 -> "FizzBuzz"
          rem(n, 3) == 0 -> "Fizz"
          rem(n, 5) == 0 -> "Buzz"
          true -> to_string(n)
        end
      end

      assert fizzbuzz.(15) == "FizzBuzz"
      assert fizzbuzz.(9) == "Fizz"
      assert fizzbuzz.(10) == "Buzz"
      assert fizzbuzz.(7) == "7"
    end
  end

  describe "with" do
    test "with chains pattern matches" do
      user = %{name: "Alice", age: 30}

      result = with {:ok, name} <- Map.fetch(user, :name),
                    {:ok, age} <- Map.fetch(user, :age) do
        "#{name} is #{age} years old"
      end

      assert result == "Alice is 30 years old"
    end

    test "with returns the non-matching value on failure" do
      user = %{name: "Alice"}

      result = with {:ok, name} <- Map.fetch(user, :name),
                    {:ok, age} <- Map.fetch(user, :age) do
        "#{name} is #{age} years old"
      end

      # Map.fetch returns :error when key is missing
      assert result == :error
      # Suppresses unused variable warning by using name in both branches
      _ = user
    end

    test "with else clause" do
      user = %{name: "Alice"}

      result = with {:ok, _name} <- Map.fetch(user, :name),
                    {:ok, _age} <- Map.fetch(user, :age) do
        "found both"
      else
        :error -> "missing key"
        _ -> "something else went wrong"
      end

      assert result == "missing key"
    end

    test "with for validating input" do
      validate = fn params ->
        with {:ok, name} when byte_size(name) > 0 <- Map.fetch(params, :name),
             {:ok, age} when is_integer(age) and age > 0 <- Map.fetch(params, :age) do
          {:ok, %{name: name, age: age}}
        else
          :error -> {:error, "missing field"}
          {:ok, _} -> {:error, "invalid value"}
        end
      end

      assert validate.(%{name: "Alice", age: 30}) == {:ok, %{name: "Alice", age: 30}}
      assert validate.(%{name: "Alice"}) == {:error, "missing field"}
    end
  end

  describe "try/rescue/catch/after" do
    test "rescue from exceptions" do
      result = try do
        1 / 0
      rescue
        ArithmeticError -> "can't divide by zero"
      end
      assert result == "can't divide by zero"
    end

    test "rescue and capture the exception" do
      result = try do
        raise "oops"
      rescue
        e in RuntimeError -> e.message
      end
      assert result == "oops"
    end

    test "after always runs (like finally)" do
      # after is for side effects, its return value is not used
      result = try do
        42
      after
        # cleanup code here
        :cleanup
      end
      assert result == 42
    end

    test "throw and catch" do
      result = try do
        throw(:some_value)
      catch
        :throw, value -> "caught: #{value}"
      end
      assert result == "caught: some_value"
    end
  end
end
