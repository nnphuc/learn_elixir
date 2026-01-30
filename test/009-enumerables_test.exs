ExUnit.start()

defmodule EnumerablesTest do
  use ExUnit.Case, async: true

  # =============================================================
  # 009 - Enumerables (Enum module)
  # The Enum module provides functions for working with
  # enumerables (lists, maps, ranges, etc.).
  # All Enum functions are eager (process entire collection).
  # =============================================================

  describe "Enum.map/2 - transform each element" do
    test "double each number" do
      assert Enum.map([1, 2, 3], fn x -> x * 2 end) == [2, 4, 6]
    end

    test "with capture syntax" do
      assert Enum.map([1, 2, 3], &(&1 * 2)) == [2, 4, 6]
    end

    test "map over a range" do
      assert Enum.map(1..5, &(&1 * &1)) == [1, 4, 9, 16, 25]
    end
  end

  describe "Enum.filter/2 and Enum.reject/2" do
    test "filter keeps elements where function returns truthy" do
      evens = Enum.filter(1..10, fn x -> rem(x, 2) == 0 end)
      assert evens == [2, 4, 6, 8, 10]
    end

    test "reject removes elements where function returns truthy" do
      odds = Enum.reject(1..10, &(rem(&1, 2) == 0))
      assert odds == [1, 3, 5, 7, 9]
    end
  end

  describe "Enum.reduce/2 and Enum.reduce/3" do
    test "reduce with accumulator" do
      sum = Enum.reduce([1, 2, 3, 4], 0, fn x, acc -> x + acc end)
      assert sum == 10
    end

    test "reduce without explicit accumulator uses first element" do
      sum = Enum.reduce([1, 2, 3, 4], &+/2)
      assert sum == 10
    end

    test "build a map with reduce" do
      words = ["hello", "world", "hello", "elixir", "hello", "world"]

      freq = Enum.reduce(words, %{}, fn word, acc ->
        Map.update(acc, word, 1, &(&1 + 1))
      end)

      assert freq == %{"hello" => 3, "world" => 2, "elixir" => 1}
    end

    test "reverse a list with reduce" do
      reversed = Enum.reduce([1, 2, 3, 4], [], fn x, acc -> [x | acc] end)
      assert reversed == [4, 3, 2, 1]
    end
  end

  describe "Enum.sort/1 and Enum.sort/2" do
    test "default ascending sort" do
      assert Enum.sort([3, 1, 4, 1, 5]) == [1, 1, 3, 4, 5]
    end

    test "descending sort" do
      assert Enum.sort([3, 1, 4, 1, 5], :desc) == [5, 4, 3, 1, 1]
    end

    test "sort with custom comparator" do
      people = [{"Alice", 30}, {"Bob", 25}, {"Charlie", 35}]
      sorted = Enum.sort(people, fn {_, a}, {_, b} -> a <= b end)
      assert sorted == [{"Bob", 25}, {"Alice", 30}, {"Charlie", 35}]
    end

    test "sort_by for sorting by a derived value" do
      words = ["banana", "apple", "cherry", "date"]
      sorted = Enum.sort_by(words, &String.length/1)
      assert sorted == ["date", "apple", "banana", "cherry"]
    end
  end

  describe "Enum.find/2 and Enum.find_index/2" do
    test "find returns first matching element" do
      assert Enum.find([2, 4, 6, 7, 8], &(rem(&1, 2) != 0)) == 7
    end

    test "find returns nil if not found" do
      assert Enum.find([2, 4, 6], &(rem(&1, 2) != 0)) == nil
    end

    test "find_index returns index of first match" do
      assert Enum.find_index(["a", "b", "c"], &(&1 == "b")) == 1
    end
  end

  describe "Enum.any?/2 and Enum.all?/2" do
    test "any? checks if at least one element matches" do
      assert Enum.any?([1, 2, 3], &(&1 > 2))
      refute Enum.any?([1, 2, 3], &(&1 > 5))
    end

    test "all? checks if all elements match" do
      assert Enum.all?([2, 4, 6], &(rem(&1, 2) == 0))
      refute Enum.all?([2, 3, 6], &(rem(&1, 2) == 0))
    end

    test "member? checks if value is in collection" do
      assert Enum.member?([1, 2, 3], 2)
      refute Enum.member?([1, 2, 3], 5)
    end
  end

  describe "Enum.take/2 and Enum.drop/2" do
    test "take first n elements" do
      assert Enum.take([1, 2, 3, 4, 5], 3) == [1, 2, 3]
    end

    test "take last n with negative" do
      assert Enum.take([1, 2, 3, 4, 5], -2) == [4, 5]
    end

    test "drop first n elements" do
      assert Enum.drop([1, 2, 3, 4, 5], 2) == [3, 4, 5]
    end

    test "take_while and drop_while" do
      assert Enum.take_while([1, 2, 3, 4, 5], &(&1 < 4)) == [1, 2, 3]
      assert Enum.drop_while([1, 2, 3, 4, 5], &(&1 < 4)) == [4, 5]
    end
  end

  describe "Enum.each/2" do
    test "each iterates for side effects (returns :ok)" do
      result = Enum.each([1, 2, 3], fn _x ->
        # side effects like IO.puts go here
        :whatever
      end)
      assert result == :ok
    end
  end

  describe "Enum.flat_map/2 and Enum.flat_map_reduce/3" do
    test "flat_map maps and flattens one level" do
      result = Enum.flat_map([1, 2, 3], fn x -> [x, x * 2] end)
      assert result == [1, 2, 2, 4, 3, 6]
    end

    test "flat_map to expand ranges" do
      result = Enum.flat_map(1..3, fn x -> 1..x |> Enum.to_list() end)
      assert result == [1, 1, 2, 1, 2, 3]
    end
  end

  describe "Enum.group_by/2" do
    test "group elements by a function" do
      grouped = Enum.group_by(1..10, &(rem(&1, 3)))
      assert grouped[0] == [3, 6, 9]
      assert grouped[1] == [1, 4, 7, 10]
      assert grouped[2] == [2, 5, 8]
    end

    test "group words by length" do
      words = ["hi", "hello", "hey", "howdy", "yo"]
      grouped = Enum.group_by(words, &String.length/1)
      assert grouped[2] == ["hi", "yo"]
      assert grouped[3] == ["hey"]
      assert grouped[5] == ["hello", "howdy"]
    end
  end

  describe "Enum.zip/2 and Enum.unzip/1" do
    test "zip combines two lists into tuples" do
      assert Enum.zip([1, 2, 3], [:a, :b, :c]) == [{1, :a}, {2, :b}, {3, :c}]
    end

    test "zip truncates to shorter list" do
      assert Enum.zip([1, 2, 3], [:a, :b]) == [{1, :a}, {2, :b}]
    end

    test "unzip separates list of tuples" do
      assert Enum.unzip([{1, :a}, {2, :b}, {3, :c}]) == {[1, 2, 3], [:a, :b, :c]}
    end

    test "zip_with applies a function while zipping" do
      result = Enum.zip_with([1, 2, 3], [10, 20, 30], &+/2)
      assert result == [11, 22, 33]
    end
  end

  describe "Enum.chunk_every/2 and Enum.chunk_by/2" do
    test "chunk_every splits into fixed-size chunks" do
      assert Enum.chunk_every([1, 2, 3, 4, 5, 6], 2) == [[1, 2], [3, 4], [5, 6]]
    end

    test "last chunk may be smaller" do
      assert Enum.chunk_every([1, 2, 3, 4, 5], 2) == [[1, 2], [3, 4], [5]]
    end

    test "chunk_by groups consecutive elements" do
      result = Enum.chunk_by([1, 1, 2, 2, 2, 3, 1, 1], &(&1))
      assert result == [[1, 1], [2, 2, 2], [3], [1, 1]]
    end
  end

  describe "Enum convenience functions" do
    test "sum and product" do
      assert Enum.sum([1, 2, 3, 4]) == 10
      assert Enum.product([1, 2, 3, 4]) == 24
    end

    test "min, max, min_max" do
      assert Enum.min([3, 1, 4, 1, 5]) == 1
      assert Enum.max([3, 1, 4, 1, 5]) == 5
      assert Enum.min_max([3, 1, 4, 1, 5]) == {1, 5}
    end

    test "count" do
      assert Enum.count([1, 2, 3]) == 3
      assert Enum.count([1, 2, 3, 4, 5], &(rem(&1, 2) == 0)) == 2
    end

    test "join" do
      assert Enum.join([1, 2, 3], ", ") == "1, 2, 3"
      assert Enum.join(["a", "b", "c"]) == "abc"
    end

    test "frequencies" do
      result = Enum.frequencies(["a", "b", "a", "c", "b", "a"])
      assert result == %{"a" => 3, "b" => 2, "c" => 1}
    end

    test "with_index" do
      result = Enum.with_index(["a", "b", "c"])
      assert result == [{"a", 0}, {"b", 1}, {"c", 2}]
    end

    test "dedup removes consecutive duplicates" do
      assert Enum.dedup([1, 1, 2, 2, 3, 1, 1]) == [1, 2, 3, 1]
    end

    test "reverse" do
      assert Enum.reverse([1, 2, 3]) == [3, 2, 1]
    end

    test "shuffle returns a randomly ordered list" do
      list = Enum.to_list(1..100)
      shuffled = Enum.shuffle(list)
      # Very unlikely to stay in same order
      assert Enum.sort(shuffled) == list
    end
  end

  describe "Enum with maps" do
    test "iterating over maps yields {key, value} tuples" do
      map = %{a: 1, b: 2, c: 3}
      result = Enum.map(map, fn {k, v} -> {k, v * 2} end)
      assert Enum.sort(result) == [a: 2, b: 4, c: 6]
    end

    test "filtering maps" do
      map = %{a: 1, b: 2, c: 3, d: 4}
      result = map
        |> Enum.filter(fn {_k, v} -> rem(v, 2) == 0 end)
        |> Map.new()
      assert result == %{b: 2, d: 4}
    end

    test "into to collect back into a map" do
      result = Enum.into([a: 1, b: 2], %{})
      assert result == %{a: 1, b: 2}
    end
  end
end
