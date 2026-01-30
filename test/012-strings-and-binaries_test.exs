ExUnit.start()

defmodule StringsAndBinariesTest do
  use ExUnit.Case, async: true

  # =============================================================
  # 012 - Strings and Binaries
  # Strings in Elixir are UTF-8 encoded binaries.
  # Binaries are sequences of bytes.
  # Charlists are lists of code points (different from strings).
  # =============================================================

  describe "strings are binaries" do
    test "strings are UTF-8 binaries" do
      assert is_binary("hello")
      assert String.valid?("hello")
    end

    test "byte_size vs String.length" do
      # ASCII: 1 byte per character
      assert byte_size("hello") == 5
      assert String.length("hello") == 5

      # Unicode: multi-byte characters
      assert String.length("café") == 4
      assert byte_size("café") == 5
    end
  end

  describe "string operations" do
    test "concatenation" do
      assert "hello" <> " " <> "world" == "hello world"
    end

    test "interpolation" do
      name = "Elixir"
      assert "Hello, #{name}!" == "Hello, Elixir!"
      assert "1 + 1 = #{1 + 1}" == "1 + 1 = 2"
    end

    test "String.length/1" do
      assert String.length("hello") == 5
      assert String.length("") == 0
    end

    test "String.upcase/1 and String.downcase/1" do
      assert String.upcase("hello") == "HELLO"
      assert String.downcase("HELLO") == "hello"
    end

    test "String.capitalize/1" do
      assert String.capitalize("hello world") == "Hello world"
    end

    test "String.trim/1" do
      assert String.trim("  hello  ") == "hello"
      assert String.trim_leading("  hello  ") == "hello  "
      assert String.trim_trailing("  hello  ") == "  hello"
    end

    test "String.split/2" do
      assert String.split("a,b,c", ",") == ["a", "b", "c"]
      assert String.split("hello world") == ["hello", "world"]
      assert String.split("a--b--c", "--") == ["a", "b", "c"]
    end

    test "String.replace/3" do
      assert String.replace("hello world", "world", "elixir") == "hello elixir"
      assert String.replace("aabba", "a", "x") == "xxbbx"
    end

    test "String.contains?/2" do
      assert String.contains?("hello world", "world")
      refute String.contains?("hello world", "xyz")
      assert String.contains?("hello", ["he", "xyz"])  # any match
    end

    test "String.starts_with?/2 and String.ends_with?/2" do
      assert String.starts_with?("hello", "hel")
      assert String.ends_with?("hello", "llo")
    end

    test "String.reverse/1" do
      assert String.reverse("hello") == "olleh"
    end

    test "String.duplicate/2" do
      assert String.duplicate("ha", 3) == "hahaha"
    end

    test "String.pad_leading/3 and String.pad_trailing/3" do
      assert String.pad_leading("42", 5, "0") == "00042"
      assert String.pad_trailing("hi", 5, ".") == "hi..."
    end
  end

  describe "string slicing and access" do
    test "String.at/2" do
      assert String.at("hello", 0) == "h"
      assert String.at("hello", -1) == "o"
    end

    test "String.slice/2 with range" do
      assert String.slice("hello world", 0..4) == "hello"
      assert String.slice("hello world", 6..-1//1) == "world"
    end

    test "String.slice/3 with start and length" do
      assert String.slice("hello world", 6, 5) == "world"
    end

    test "String.first/1 and String.last/1" do
      assert String.first("hello") == "h"
      assert String.last("hello") == "o"
    end

    test "String.graphemes/1 splits into individual characters" do
      assert String.graphemes("hello") == ["h", "e", "l", "l", "o"]
    end

    test "String.codepoints/1" do
      assert String.codepoints("hello") == ["h", "e", "l", "l", "o"]
    end
  end

  describe "pattern matching with strings" do
    test "match prefix with <>" do
      "hello " <> rest = "hello world"
      assert rest == "world"
    end

    test "binary pattern matching" do
      <<first_byte, rest::binary>> = "hello"
      assert first_byte == ?h  # 104
      assert rest == "ello"
    end

    test "extracting fixed-size fields" do
      <<a::8, b::8, c::8>> = "ABC"
      assert a == ?A
      assert b == ?B
      assert c == ?C
    end
  end

  describe "binaries" do
    test "binary literal" do
      binary = <<1, 2, 3>>
      assert byte_size(binary) == 3
    end

    test "binaries are sequences of bytes" do
      assert <<0, 1, 2>> == <<0, 1, 2>>
      assert byte_size(<<0, 1, 2>>) == 3
    end

    test "bit-level operations" do
      # Specify number of bits
      assert <<1::4, 15::4>> == <<0x1F>>
    end

    test "string is a binary" do
      assert "hello" == <<104, 101, 108, 108, 111>>
    end
  end

  describe "charlists" do
    test "charlists are lists of code points" do
      assert ~c"hello" == [104, 101, 108, 108, 111]
      assert is_list(~c"hello")
    end

    test "converting between strings and charlists" do
      assert to_string(~c"hello") == "hello"
      assert to_charlist("hello") == ~c"hello"
    end

    test "charlists are mainly for Erlang interop" do
      # Many Erlang functions expect charlists
      assert :string.uppercase(~c"hello") == ~c"HELLO"
    end
  end

  describe "sigils" do
    test "~s for strings (allows interpolation)" do
      name = "world"
      assert ~s(Hello #{name}) == "Hello world"
    end

    test "~S for strings (no interpolation)" do
      assert ~S(Hello #{name}) == "Hello \#{name}"
    end

    test "~w for word lists" do
      assert ~w(foo bar baz) == ["foo", "bar", "baz"]
      assert ~w(foo bar baz)a == [:foo, :bar, :baz]
    end

    test "~r for regular expressions" do
      regex = ~r/hello/i
      assert Regex.match?(regex, "Hello World")
    end
  end

  describe "regular expressions" do
    test "Regex.match?/2" do
      assert Regex.match?(~r/\d+/, "abc123")
      refute Regex.match?(~r/\d+/, "abc")
    end

    test "Regex.run/2" do
      assert Regex.run(~r/(\d+)/, "abc123def") == ["123", "123"]
    end

    test "Regex.scan/2 finds all matches" do
      result = Regex.scan(~r/\d+/, "a1b22c333")
      assert result == [["1"], ["22"], ["333"]]
    end

    test "Regex.replace/3" do
      assert Regex.replace(~r/\d+/, "a1b2c3", "X") == "aXbXcX"
    end

    test "named captures" do
      regex = ~r/(?<year>\d{4})-(?<month>\d{2})-(?<day>\d{2})/
      captures = Regex.named_captures(regex, "2024-01-15")
      assert captures == %{"year" => "2024", "month" => "01", "day" => "15"}
    end
  end
end
