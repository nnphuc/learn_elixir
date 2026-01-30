ExUnit.start()

defmodule FunctionsTest do
  use ExUnit.Case, async: true

  # =============================================================
  # 006 - Functions
  # Elixir has anonymous functions (fn) and named functions (def).
  # Functions are first-class citizens.
  # =============================================================

  describe "anonymous functions" do
    test "creating and calling anonymous functions" do
      add = fn a, b -> a + b end
      assert add.(1, 2) == 3
    end

    test "note the dot when calling anonymous functions" do
      greet = fn name -> "Hello, #{name}!" end
      assert greet.("Alice") == "Hello, Alice!"
    end

    test "closures: anonymous functions capture variables" do
      x = 10
      add_x = fn y -> x + y end
      assert add_x.(5) == 15
    end

    test "multi-clause anonymous functions" do
      fizzbuzz = fn
        0, 0, _ -> "FizzBuzz"
        0, _, _ -> "Fizz"
        _, 0, _ -> "Buzz"
        _, _, n -> n
      end

      assert fizzbuzz.(0, 0, 15) == "FizzBuzz"
      assert fizzbuzz.(0, 1, 3) == "Fizz"
      assert fizzbuzz.(1, 0, 5) == "Buzz"
      assert fizzbuzz.(1, 1, 7) == 7
    end
  end

  describe "the capture operator &" do
    test "shorthand for anonymous functions" do
      double = &(&1 * 2)
      assert double.(5) == 10

      add = &(&1 + &2)
      assert add.(3, 4) == 7
    end

    test "capturing named functions" do
      # Capture a named function as a value
      upcase = &String.upcase/1
      assert upcase.("hello") == "HELLO"
    end

    test "useful with Enum functions" do
      assert Enum.map([1, 2, 3], &(&1 * 2)) == [2, 4, 6]
      assert Enum.map(["a", "b", "c"], &String.upcase/1) == ["A", "B", "C"]
    end
  end

  describe "named functions (defined in modules)" do
    defmodule MathHelper do
      def add(a, b), do: a + b

      def multiply(a, b) do
        a * b
      end

      # Multiple clauses with pattern matching
      def factorial(0), do: 1
      def factorial(n) when n > 0, do: n * factorial(n - 1)

      # Default arguments with \\
      def greet(name, greeting \\ "Hello") do
        "#{greeting}, #{name}!"
      end

      # Private function
      defp secret, do: "you can't call me from outside"

      def reveal_secret, do: secret()
    end

    test "calling named functions" do
      assert MathHelper.add(1, 2) == 3
      assert MathHelper.multiply(3, 4) == 12
    end

    test "pattern matching in function heads" do
      assert MathHelper.factorial(0) == 1
      assert MathHelper.factorial(5) == 120
    end

    test "default arguments" do
      assert MathHelper.greet("Alice") == "Hello, Alice!"
      assert MathHelper.greet("Alice", "Hi") == "Hi, Alice!"
    end

    test "private functions can't be called externally" do
      assert MathHelper.reveal_secret() == "you can't call me from outside"
      assert_raise UndefinedFunctionError, fn ->
        MathHelper.secret()
      end
    end
  end

  describe "guards" do
    defmodule TypeChecker do
      def check(x) when is_integer(x), do: "integer"
      def check(x) when is_float(x), do: "float"
      def check(x) when is_binary(x), do: "string"
      def check(x) when is_atom(x), do: "atom"
      def check(x) when is_list(x), do: "list"
      def check(_), do: "other"

      def positive?(n) when is_number(n) and n > 0, do: true
      def positive?(_), do: false
    end

    test "guards select the right clause" do
      assert TypeChecker.check(42) == "integer"
      assert TypeChecker.check(3.14) == "float"
      assert TypeChecker.check("hello") == "string"
      assert TypeChecker.check(:ok) == "atom"
      assert TypeChecker.check([1, 2]) == "list"
    end

    test "compound guards" do
      assert TypeChecker.positive?(5)
      refute TypeChecker.positive?(-3)
      refute TypeChecker.positive?("hello")
    end
  end

  describe "function arity" do
    defmodule ArityDemo do
      # These are different functions because they have different arities
      def info(x), do: "one arg: #{x}"
      def info(x, y), do: "two args: #{x}, #{y}"
    end

    test "functions with different arities are different functions" do
      assert ArityDemo.info("a") == "one arg: a"
      assert ArityDemo.info("a", "b") == "two args: a, b"
    end

    test "arity is part of the function identity" do
      # &Module.function/arity
      f1 = &ArityDemo.info/1
      f2 = &ArityDemo.info/2
      assert f1.("hello") == "one arg: hello"
      assert f2.("hello", "world") == "two args: hello, world"
    end
  end

  describe "higher-order functions" do
    test "passing functions as arguments" do
      apply_twice = fn f, x -> f.(f.(x)) end
      increment = fn x -> x + 1 end
      assert apply_twice.(increment, 5) == 7
    end

    test "returning functions" do
      multiplier = fn factor -> fn x -> x * factor end end
      triple = multiplier.(3)
      assert triple.(5) == 15
    end
  end
end
