ExUnit.start()

defmodule ModulesAndStructsTest do
  use ExUnit.Case, async: true

  # =============================================================
  # 011 - Modules and Structs
  # Modules group functions. Structs are typed maps.
  # Module attributes store metadata and constants.
  # =============================================================

  describe "modules" do
    defmodule Greeter do
      @moduledoc "A simple greeter module"

      @default_greeting "Hello"  # module attribute as constant

      def greet(name), do: "#{@default_greeting}, #{name}!"
      def greet(name, greeting), do: "#{greeting}, #{name}!"
    end

    test "calling module functions" do
      assert Greeter.greet("Alice") == "Hello, Alice!"
      assert Greeter.greet("Alice", "Hi") == "Hi, Alice!"
    end

    test "module info" do
      # Every module has __info__/1
      functions = Greeter.__info__(:functions)
      assert {:greet, 1} in functions
      assert {:greet, 2} in functions
    end
  end

  describe "module attributes" do
    defmodule Config do
      @app_name "MyApp"
      @version "1.0.0"
      @max_retries 3

      def app_name, do: @app_name
      def version, do: @version
      def max_retries, do: @max_retries
    end

    test "module attributes as constants" do
      assert Config.app_name() == "MyApp"
      assert Config.version() == "1.0.0"
      assert Config.max_retries() == 3
    end
  end

  describe "structs" do
    defmodule User do
      defstruct [:name, :email, age: 0, active: true]
    end

    test "creating a struct" do
      user = %User{name: "Alice", email: "alice@example.com"}
      assert user.name == "Alice"
      assert user.email == "alice@example.com"
      assert user.age == 0        # default value
      assert user.active == true  # default value
    end

    test "structs are maps underneath" do
      user = %User{name: "Alice"}
      assert is_map(user)
      assert user.__struct__ == User
    end

    test "updating structs" do
      user = %User{name: "Alice", age: 30}
      updated = %{user | age: 31}
      assert updated.age == 31
      assert updated.name == "Alice"
    end

    test "pattern matching with structs" do
      user = %User{name: "Alice", age: 30}
      %User{name: name, age: age} = user
      assert name == "Alice"
      assert age == 30
    end

    test "struct enforces keys" do
      # Invalid keys cause a compile-time error, so we use Code.eval_string
      assert_raise KeyError, fn ->
        Code.eval_string("""
        defmodule TempStructTest do
          def test, do: %ModulesAndStructsTest.User{invalid_key: "oops"}
        end
        """)
      end
    end
  end

  describe "structs with @enforce_keys" do
    defmodule Product do
      @enforce_keys [:name, :price]
      defstruct [:name, :price, in_stock: true]
    end

    test "enforced keys must be provided" do
      product = %Product{name: "Widget", price: 9.99}
      assert product.name == "Widget"
      assert product.price == 9.99
    end

    test "missing enforced key raises" do
      # @enforce_keys is checked at compile time, so we use struct!/2
      assert_raise ArgumentError, fn ->
        struct!(Product, name: "Widget")  # missing :price
      end
    end
  end

  describe "structs with functions" do
    defmodule BankAccount do
      defstruct [:owner, balance: 0]

      def new(owner, initial_balance \\ 0) do
        %BankAccount{owner: owner, balance: initial_balance}
      end

      def deposit(%BankAccount{} = account, amount) when amount > 0 do
        %{account | balance: account.balance + amount}
      end

      def withdraw(%BankAccount{balance: balance} = account, amount)
          when amount > 0 and amount <= balance do
        {:ok, %{account | balance: balance - amount}}
      end

      def withdraw(%BankAccount{}, _amount) do
        {:error, "insufficient funds"}
      end

      def balance(%BankAccount{balance: balance}), do: balance
    end

    test "create and use a struct with functions" do
      account = BankAccount.new("Alice", 100)
      assert BankAccount.balance(account) == 100

      account = BankAccount.deposit(account, 50)
      assert BankAccount.balance(account) == 150

      {:ok, account} = BankAccount.withdraw(account, 30)
      assert BankAccount.balance(account) == 120

      assert BankAccount.withdraw(account, 500) == {:error, "insufficient funds"}
    end
  end

  describe "alias, import, require, use" do
    test "alias shortens module names" do
      alias String, as: S
      assert S.upcase("hello") == "HELLO"
    end

    test "import brings functions into scope" do
      import Integer, only: [is_odd: 1]
      assert is_odd(3)
      refute is_odd(4)
    end

    test "require for macros" do
      require Integer
      # Integer.is_odd is a macro, needs require
      assert Integer.is_odd(3)
    end
  end

  describe "protocols (polymorphism)" do
    # Protocols define a contract that types can implement

    defprotocol Describable do
      @doc "Returns a description of the value"
      def describe(value)
    end

    defmodule Animal do
      defstruct [:species, :name]
    end

    defmodule Car do
      defstruct [:make, :model]
    end

    defimpl Describable, for: Animal do
      def describe(%Animal{species: species, name: name}) do
        "#{name} the #{species}"
      end
    end

    defimpl Describable, for: Car do
      def describe(%Car{make: make, model: model}) do
        "#{make} #{model}"
      end
    end

    test "protocol dispatches to correct implementation" do
      animal = %Animal{species: "cat", name: "Whiskers"}
      car = %Car{make: "Toyota", model: "Camry"}

      assert Describable.describe(animal) == "Whiskers the cat"
      assert Describable.describe(car) == "Toyota Camry"
    end
  end

  describe "behaviours (interfaces)" do
    # Behaviours define a set of functions a module must implement

    defmodule Shape do
      @callback area(shape :: struct()) :: number()
      @callback perimeter(shape :: struct()) :: number()
    end

    defmodule Circle do
      @behaviour Shape
      defstruct [:radius]

      @impl Shape
      def area(%Circle{radius: r}), do: :math.pi() * r * r

      @impl Shape
      def perimeter(%Circle{radius: r}), do: 2 * :math.pi() * r
    end

    defmodule Rectangle do
      @behaviour Shape
      defstruct [:width, :height]

      @impl Shape
      def area(%Rectangle{width: w, height: h}), do: w * h

      @impl Shape
      def perimeter(%Rectangle{width: w, height: h}), do: 2 * (w + h)
    end

    test "modules implementing a behaviour" do
      circle = %Circle{radius: 5}
      assert_in_delta Circle.area(circle), 78.54, 0.01
      assert_in_delta Circle.perimeter(circle), 31.42, 0.01

      rect = %Rectangle{width: 4, height: 6}
      assert Rectangle.area(rect) == 24
      assert Rectangle.perimeter(rect) == 20
    end
  end
end
