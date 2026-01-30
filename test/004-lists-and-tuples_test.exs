ExUnit.start()

defmodule ListsAndTuplesTest do
  use ExUnit.Case, async: true

  # =============================================================
  # 004 - Lists and Tuples
  # Lists are linked lists. Tuples are contiguous in memory.
  # Choose based on access patterns:
  #   - Lists: good for dynamic collections, prepending is O(1)
  #   - Tuples: good for fixed-size groups, access by index is O(1)
  # =============================================================

  describe "lists" do
    test "list literals" do
      list = [1, 2, 3]
      assert list == [1, 2, 3]
    end

    test "lists can contain mixed types" do
      list = [1, :two, "three", 4.0]
      assert length(list) == 4
    end

    test "head and tail" do
      assert hd([1, 2, 3]) == 1
      assert tl([1, 2, 3]) == [2, 3]
    end

    test "prepending is fast (O(1))" do
      list = [2, 3, 4]
      new_list = [1 | list]
      assert new_list == [1, 2, 3, 4]
    end

    test "appending is slow (O(n)) but possible" do
      list = [1, 2, 3]
      new_list = list ++ [4]
      assert new_list == [1, 2, 3, 4]
    end

    test "lists are immutable" do
      original = [1, 2, 3]
      _new = [0 | original]
      # original is unchanged
      assert original == [1, 2, 3]
    end

    test "List module functions" do
      assert List.first([1, 2, 3]) == 1
      assert List.last([1, 2, 3]) == 3
      assert List.flatten([1, [2, [3, 4]], 5]) == [1, 2, 3, 4, 5]
      assert Enum.zip([[1, 2, 3], [:a, :b, :c]]) == [{1, :a}, {2, :b}, {3, :c}]
    end

    test "Enum.at for accessing by index" do
      list = [10, 20, 30, 40]
      assert Enum.at(list, 0) == 10
      assert Enum.at(list, 2) == 30
      assert Enum.at(list, 10) == nil
      assert Enum.at(list, 10, :default) == :default
    end

    test "length/1 counts elements" do
      assert length([]) == 0
      assert length([1, 2, 3]) == 3
    end
  end

  describe "charlists" do
    test "single-quoted strings are charlists (list of code points)" do
      assert ~c"hello" == [104, 101, 108, 108, 111]
    end

    test "charlists vs strings" do
      charlist = ~c"hello"
      string = "hello"
      assert is_list(charlist)
      assert is_binary(string)
      assert to_string(charlist) == string
    end
  end

  describe "tuples" do
    test "tuple literals" do
      tuple = {1, 2, 3}
      assert tuple == {1, 2, 3}
    end

    test "tuples can contain mixed types" do
      tuple = {:ok, "hello", 42}
      assert tuple_size(tuple) == 3
    end

    test "accessing elements by index (0-based)" do
      tuple = {:a, :b, :c, :d}
      assert elem(tuple, 0) == :a
      assert elem(tuple, 2) == :c
    end

    test "putting a value at an index (returns new tuple)" do
      tuple = {:a, :b, :c}
      new_tuple = put_elem(tuple, 1, :x)
      assert new_tuple == {:a, :x, :c}
      assert tuple == {:a, :b, :c}  # original unchanged
    end

    test "tuple_size/1" do
      assert tuple_size({}) == 0
      assert tuple_size({1, 2, 3}) == 3
    end

    test "Tuple module functions" do
      assert Tuple.insert_at({1, 2}, 2, 3) == {1, 2, 3}
      assert Tuple.delete_at({1, 2, 3}, 1) == {1, 3}
      assert Tuple.insert_at({1, 3}, 1, 2) == {1, 2, 3}
      assert Tuple.to_list({1, 2, 3}) == [1, 2, 3]
    end
  end

  describe "common patterns with tuples" do
    test "{:ok, value} pattern for success" do
      result = {:ok, 42}
      {:ok, value} = result
      assert value == 42
    end

    test "{:error, reason} pattern for failure" do
      result = {:error, "not found"}
      {:error, reason} = result
      assert reason == "not found"
    end

    test "returning tuples from functions" do
      result = Map.fetch(%{name: "Alice"}, :name)
      assert result == {:ok, "Alice"}

      result = Map.fetch(%{name: "Alice"}, :age)
      assert result == :error
    end
  end

  describe "lists vs tuples" do
    test "list concatenation creates a new list" do
      a = [1, 2, 3]
      b = [4, 5, 6]
      assert a ++ b == [1, 2, 3, 4, 5, 6]
    end

    test "converting between lists and tuples" do
      list = [1, 2, 3]
      tuple = {1, 2, 3}

      assert List.to_tuple(list) == tuple
      assert Tuple.to_list(tuple) == list
    end
  end

  describe "ranges" do
    test "ranges represent a sequence of integers" do
      range = 1..5
      assert Enum.to_list(range) == [1, 2, 3, 4, 5]
    end

    test "ranges with step" do
      assert Enum.to_list(1..10//2) == [1, 3, 5, 7, 9]
      assert Enum.to_list(10..1//-3) == [10, 7, 4, 1]
    end

    test "checking membership" do
      assert 3 in 1..5
      refute 6 in 1..5
    end

    test "range size" do
      assert Range.size(1..10) == 10
      assert Range.size(1..10//3) == 4
    end
  end
end
