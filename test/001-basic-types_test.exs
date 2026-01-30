ExUnit.start()

defmodule BasicTypesTest do
  use ExUnit.Case, async: true

  # =============================================================
  # 001 - Basic Types
  # Elixir has several basic types: integers, floats, booleans,
  # atoms, strings, lists, tuples, and more.
  # =============================================================

  describe "integers" do
    test "integer literals" do
      assert 1 + 2 == 3
      assert 1_000_000 == 1000000  # underscores for readability
    end

    test "different bases" do
      assert 0b1010 == 10   # binary
      assert 0o777 == 511   # octal
      assert 0xFF == 255    # hexadecimal
    end

    test "integers have arbitrary precision" do
      # Elixir integers can be arbitrarily large
      big = 1_000_000_000_000_000_000_000
      assert big * 2 == 2_000_000_000_000_000_000_000
    end
  end

  describe "floats" do
    test "float literals require a dot with digits on both sides" do
      assert 1.0 + 2.5 == 3.5
    end

    test "scientific notation" do
      assert 1.0e3 == 1000.0
      assert 1.0e-2 == 0.01
    end

    test "float precision" do
      # Floats are 64-bit double precision IEEE 754
      # Be careful with float comparisons
      assert 0.1 + 0.2 != 0.3
      assert_in_delta 0.1 + 0.2, 0.3, 0.0001
    end
  end

  describe "booleans" do
    test "true and false are atoms" do
      assert true == true
      assert false == false
      assert is_boolean(true)
      assert is_boolean(false)
    end

    test "true and false are actually atoms" do
      assert true == :true
      assert false == :false
      assert is_atom(true)
      assert is_atom(false)
    end
  end

  describe "atoms" do
    test "atoms are constants whose name is their value" do
      assert :hello == :hello
      assert :world == :world
    end

    test "atoms are used extensively in Elixir" do
      assert :ok == :ok
      assert :error == :error
    end

    test "module names are atoms" do
      assert is_atom(String)
      assert String == :"Elixir.String"
    end

    test "nil is also an atom" do
      assert nil == :nil
      assert is_atom(nil)
    end
  end

  describe "strings" do
    test "strings are UTF-8 encoded binaries" do
      assert "hello" == "hello"
      assert is_binary("hello")
    end

    test "string interpolation" do
      name = "world"
      assert "hello #{name}" == "hello world"
    end

    test "string concatenation" do
      assert "hello" <> " " <> "world" == "hello world"
    end

    test "multi-line strings with heredoc" do
      text = """
      hello
      world
      """
      assert text == "hello\nworld\n"
    end

    test "string length vs byte size" do
      ascii = "hello"
      assert String.length(ascii) == 5
      assert byte_size(ascii) == 5

      # UTF-8 characters may use more than 1 byte
      unicode = "héllo"
      assert String.length(unicode) == 5
      assert byte_size(unicode) > 5
    end
  end

  describe "type checking functions" do
    test "is_integer/1" do
      assert is_integer(42)
      refute is_integer(42.0)
    end

    test "is_float/1" do
      assert is_float(42.0)
      refute is_float(42)
    end

    test "is_number/1" do
      assert is_number(42)
      assert is_number(42.0)
    end

    test "is_atom/1" do
      assert is_atom(:hello)
      assert is_atom(true)
      assert is_atom(nil)
    end

    test "is_binary/1 (strings are binaries)" do
      assert is_binary("hello")
      refute is_binary(:hello)
    end

    test "is_boolean/1" do
      assert is_boolean(true)
      assert is_boolean(false)
      refute is_boolean(:true_ish)
    end
  end
end
