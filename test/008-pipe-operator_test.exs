ExUnit.start()

defmodule PipeOperatorTest do
  use ExUnit.Case, async: true

  # =============================================================
  # 008 - The Pipe Operator |>
  # The pipe operator passes the result of one expression as
  # the first argument to the next function call.
  # It makes code read left-to-right instead of inside-out.
  # =============================================================

  describe "basic pipe usage" do
    test "pipe passes result as first argument" do
      # Without pipe (inside-out reading):
      result1 = String.upcase(String.trim("  hello  "))

      # With pipe (left-to-right reading):
      result2 = "  hello  " |> String.trim() |> String.upcase()

      assert result1 == result2
      assert result1 == "HELLO"
    end

    test "chaining multiple transformations" do
      result = "  Hello, World!  "
        |> String.trim()
        |> String.downcase()
        |> String.replace(",", "")
        |> String.replace("!", "")
        |> String.split(" ")

      assert result == ["hello", "world"]
    end

    test "pipe with Enum functions" do
      result = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
        |> Enum.filter(&(rem(&1, 2) == 0))  # keep even numbers
        |> Enum.map(&(&1 * &1))              # square them
        |> Enum.sum()                         # sum them up

      assert result == 4 + 16 + 36 + 64 + 100
      assert result == 220
    end
  end

  describe "pipe with different functions" do
    test "pipe with String functions" do
      result = "hello world"
        |> String.split(" ")
        |> Enum.map(&String.capitalize/1)
        |> Enum.join(" ")

      assert result == "Hello World"
    end

    test "pipe with Map functions" do
      result = %{a: 1, b: 2, c: 3}
        |> Map.put(:d, 4)
        |> Map.delete(:a)
        |> Map.to_list()
        |> Enum.sort()

      assert result == [b: 2, c: 3, d: 4]
    end

    test "pipe with Integer functions" do
      result = -42
        |> abs()
        |> Integer.to_string()
        |> String.pad_leading(5, "0")

      assert result == "00042"
    end
  end

  describe "pipe with anonymous functions" do
    test "use dot notation with anonymous functions in pipe" do
      double = fn x -> x * 2 end

      # Can't pipe directly into anonymous functions like this:
      #   5 |> double.()  -- this doesn't work
      # Instead, use then/2:
      result = 5 |> then(double)

      assert result == 10
    end

    test "then/2 for custom transformations" do
      result = 10
        |> then(fn x -> x * 2 end)
        |> then(fn x -> x + 1 end)

      assert result == 21
    end
  end

  describe "pipe best practices" do
    test "start a pipeline with raw data" do
      # Good: start with data, transform step by step
      result = "the quick brown fox"
        |> String.split(" ")
        |> Enum.count()

      assert result == 4
    end

    test "each step should be a clear transformation" do
      result = [3, 1, 4, 1, 5, 9, 2, 6, 5, 3, 5]
        |> Enum.uniq()         # remove duplicates
        |> Enum.sort()         # sort ascending
        |> Enum.reverse()      # reverse to descending
        |> Enum.take(3)        # take top 3

      assert result == [9, 6, 5]
    end
  end

  describe "pipe vs nested calls comparison" do
    test "nested calls (hard to read)" do
      result = Enum.join(Enum.map(String.split("hello world", " "), &String.upcase/1), "-")
      assert result == "HELLO-WORLD"
    end

    test "same thing with pipe (easy to read)" do
      result = "hello world"
        |> String.split(" ")
        |> Enum.map(&String.upcase/1)
        |> Enum.join("-")

      assert result == "HELLO-WORLD"
    end
  end

  describe "tap/2 for side effects" do
    test "tap runs a function for side effects and returns the original value" do
      result = [1, 2, 3]
        |> Enum.map(&(&1 * 2))
        |> tap(fn list ->
          # You could log or inspect here
          # The return value of tap's function is ignored
          assert list == [2, 4, 6]
        end)
        |> Enum.sum()

      assert result == 12
    end
  end
end
