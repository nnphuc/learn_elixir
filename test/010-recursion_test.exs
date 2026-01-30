ExUnit.start()

defmodule RecursionTest do
  use ExUnit.Case, async: true

  # =============================================================
  # 010 - Recursion
  # Elixir relies on recursion instead of loops.
  # Pattern matching + recursion = powerful list processing.
  # Tail-call optimization prevents stack overflow.
  # =============================================================

  # Helper modules with recursive functions
  defmodule BasicRecursion do
    # Count down from n to 1
    def countdown(0), do: []
    def countdown(n) when n > 0, do: [n | countdown(n - 1)]

    # Sum of numbers from 1 to n
    def sum(0), do: 0
    def sum(n) when n > 0, do: n + sum(n - 1)

    # Fibonacci (naive, for learning purposes)
    def fib(0), do: 0
    def fib(1), do: 1
    def fib(n) when n > 1, do: fib(n - 1) + fib(n - 2)
  end

  defmodule TailRecursion do
    # Tail-recursive sum (accumulator pattern)
    def sum(n), do: sum(n, 0)
    defp sum(0, acc), do: acc
    defp sum(n, acc) when n > 0, do: sum(n - 1, acc + n)

    # Tail-recursive factorial
    def factorial(n), do: factorial(n, 1)
    defp factorial(0, acc), do: acc
    defp factorial(n, acc) when n > 0, do: factorial(n - 1, n * acc)

    # Tail-recursive fibonacci
    def fib(n), do: fib(n, 0, 1)
    defp fib(0, a, _b), do: a
    defp fib(n, a, b) when n > 0, do: fib(n - 1, b, a + b)
  end

  defmodule ListRecursion do
    # Length of a list
    def list_length([]), do: 0
    def list_length([_ | tail]), do: 1 + list_length(tail)

    # Sum of a list
    def sum([]), do: 0
    def sum([head | tail]), do: head + sum(tail)

    # Map: apply function to each element
    def map([], _func), do: []
    def map([head | tail], func), do: [func.(head) | map(tail, func)]

    # Filter: keep elements where function returns true
    def filter([], _func), do: []
    def filter([head | tail], func) do
      if func.(head) do
        [head | filter(tail, func)]
      else
        filter(tail, func)
      end
    end

    # Reduce: fold list into a single value
    def reduce([], acc, _func), do: acc
    def reduce([head | tail], acc, func) do
      reduce(tail, func.(head, acc), func)
    end

    # Reverse (tail-recursive with accumulator)
    def reverse(list), do: reverse(list, [])
    defp reverse([], acc), do: acc
    defp reverse([head | tail], acc), do: reverse(tail, [head | acc])

    # Flatten nested lists
    def flatten([]), do: []
    def flatten([head | tail]) when is_list(head) do
      flatten(head) ++ flatten(tail)
    end
    def flatten([head | tail]), do: [head | flatten(tail)]
  end

  describe "basic recursion" do
    test "countdown" do
      assert BasicRecursion.countdown(5) == [5, 4, 3, 2, 1]
      assert BasicRecursion.countdown(0) == []
    end

    test "sum of 1 to n" do
      assert BasicRecursion.sum(0) == 0
      assert BasicRecursion.sum(5) == 15
      assert BasicRecursion.sum(10) == 55
    end

    test "fibonacci" do
      assert BasicRecursion.fib(0) == 0
      assert BasicRecursion.fib(1) == 1
      assert BasicRecursion.fib(6) == 8
      assert BasicRecursion.fib(10) == 55
    end
  end

  describe "tail recursion with accumulators" do
    test "tail-recursive sum" do
      assert TailRecursion.sum(0) == 0
      assert TailRecursion.sum(5) == 15
      assert TailRecursion.sum(100) == 5050
    end

    test "tail-recursive factorial" do
      assert TailRecursion.factorial(0) == 1
      assert TailRecursion.factorial(5) == 120
      assert TailRecursion.factorial(10) == 3_628_800
    end

    test "tail-recursive fibonacci" do
      assert TailRecursion.fib(0) == 0
      assert TailRecursion.fib(1) == 1
      assert TailRecursion.fib(10) == 55
      # This can handle large values without stack overflow
      assert TailRecursion.fib(50) == 12_586_269_025
    end

    test "tail recursion vs body recursion give same results" do
      assert BasicRecursion.sum(10) == TailRecursion.sum(10)
      assert BasicRecursion.fib(10) == TailRecursion.fib(10)
    end
  end

  describe "recursive list processing" do
    test "custom length" do
      assert ListRecursion.list_length([]) == 0
      assert ListRecursion.list_length([1, 2, 3]) == 3
    end

    test "custom sum" do
      assert ListRecursion.sum([]) == 0
      assert ListRecursion.sum([1, 2, 3, 4]) == 10
    end

    test "custom map" do
      assert ListRecursion.map([1, 2, 3], &(&1 * 2)) == [2, 4, 6]
      assert ListRecursion.map([], &(&1 * 2)) == []
    end

    test "custom filter" do
      assert ListRecursion.filter([1, 2, 3, 4, 5], &(rem(&1, 2) == 0)) == [2, 4]
    end

    test "custom reduce" do
      assert ListRecursion.reduce([1, 2, 3, 4], 0, &+/2) == 10
      assert ListRecursion.reduce([1, 2, 3], [], fn x, acc -> [x * 2 | acc] end) == [6, 4, 2]
    end

    test "custom reverse" do
      assert ListRecursion.reverse([1, 2, 3]) == [3, 2, 1]
      assert ListRecursion.reverse([]) == []
    end

    test "custom flatten" do
      assert ListRecursion.flatten([1, [2, [3, 4]], 5]) == [1, 2, 3, 4, 5]
      assert ListRecursion.flatten([[1, 2], [3, [4, 5]]]) == [1, 2, 3, 4, 5]
      assert ListRecursion.flatten([]) == []
    end
  end

  describe "recursion patterns" do
    defmodule Patterns do
      # Process until condition (while-loop equivalent)
      def collatz(1), do: [1]
      def collatz(n) when rem(n, 2) == 0, do: [n | collatz(div(n, 2))]
      def collatz(n), do: [n | collatz(3 * n + 1)]

      # Generate a range (for-loop equivalent)
      def range(from, to) when from > to, do: []
      def range(from, to), do: [from | range(from + 1, to)]

      # Binary search (divide and conquer)
      def binary_search(list, target) do
        sorted = Enum.sort(list)
        do_search(sorted, target, 0, length(sorted) - 1)
      end

      defp do_search(_list, _target, low, high) when low > high, do: :not_found
      defp do_search(list, target, low, high) do
        mid = div(low + high, 2)
        value = Enum.at(list, mid)
        cond do
          value == target -> {:found, mid}
          value < target -> do_search(list, target, mid + 1, high)
          value > target -> do_search(list, target, low, mid - 1)
        end
      end
    end

    test "collatz sequence" do
      assert Patterns.collatz(1) == [1]
      assert Patterns.collatz(6) == [6, 3, 10, 5, 16, 8, 4, 2, 1]
    end

    test "generate a range" do
      assert Patterns.range(1, 5) == [1, 2, 3, 4, 5]
      assert Patterns.range(5, 3) == []
    end

    test "binary search" do
      list = [1, 3, 5, 7, 9, 11, 13]
      assert Patterns.binary_search(list, 7) == {:found, 3}
      assert Patterns.binary_search(list, 4) == :not_found
    end
  end
end
