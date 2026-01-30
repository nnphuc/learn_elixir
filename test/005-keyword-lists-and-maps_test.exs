ExUnit.start()

defmodule KeywordListsAndMapsTest do
  use ExUnit.Case, async: true

  # =============================================================
  # 005 - Keyword Lists and Maps
  # Keyword lists: ordered list of {atom, value} tuples.
  # Maps: key-value store with any type as key.
  # =============================================================

  describe "keyword lists" do
    test "keyword lists are lists of {atom, value} tuples" do
      kw = [{:name, "Alice"}, {:age, 30}]
      # Shorthand syntax:
      kw2 = [name: "Alice", age: 30]
      assert kw == kw2
    end

    test "keyword lists allow duplicate keys" do
      kw = [a: 1, a: 2, b: 3]
      assert length(kw) == 3
    end

    test "accessing values" do
      kw = [name: "Alice", age: 30]
      assert kw[:name] == "Alice"
      assert kw[:age] == 30
      assert kw[:missing] == nil
    end

    test "Keyword module functions" do
      kw = [name: "Alice", age: 30]

      assert Keyword.get(kw, :name) == "Alice"
      assert Keyword.get(kw, :missing, "default") == "default"
      assert Keyword.has_key?(kw, :name)
      assert Keyword.keys(kw) == [:name, :age]
      assert Keyword.values(kw) == ["Alice", 30]
    end

    test "with duplicate keys, first value wins for access" do
      kw = [a: 1, a: 2]
      assert kw[:a] == 1
      assert Keyword.get_values(kw, :a) == [1, 2]
    end

    test "keyword lists are often used for options" do
      # Functions often accept keyword lists as the last argument
      # The brackets can be omitted when it's the last argument
      result = String.split("hello world foo", " ", trim: true)
      assert result == ["hello", "world", "foo"]
    end

    test "modifying keyword lists" do
      kw = [name: "Alice", age: 30]

      updated = Keyword.put(kw, :age, 31)
      assert Keyword.get(updated, :age) == 31
      assert Keyword.get(updated, :name) == "Alice"

      with_new = Keyword.put(kw, :city, "NYC")
      assert Keyword.get(with_new, :city) == "NYC"

      deleted = Keyword.delete(kw, :age)
      assert deleted == [name: "Alice"]
    end
  end

  describe "maps" do
    test "map literals" do
      map = %{name: "Alice", age: 30}
      assert map == %{name: "Alice", age: 30}
    end

    test "maps can have any type as key" do
      map = %{"string_key" => 1, 42 => 2, :atom_key => 3}
      assert map["string_key"] == 1
      assert map[42] == 2
      assert map[:atom_key] == 3
    end

    test "atom keys have special syntax" do
      # These are equivalent:
      map1 = %{:name => "Alice", :age => 30}
      map2 = %{name: "Alice", age: 30}
      assert map1 == map2
    end

    test "accessing values with []" do
      map = %{name: "Alice", age: 30}
      assert map[:name] == "Alice"
      assert map[:missing] == nil
    end

    test "accessing atom keys with dot syntax" do
      map = %{name: "Alice", age: 30}
      assert map.name == "Alice"
      assert map.age == 30
    end

    test "dot syntax raises on missing key" do
      map = %{name: "Alice"}
      assert_raise KeyError, fn ->
        map.missing
      end
    end

    test "maps do NOT allow duplicate keys" do
      map = %{a: 1, a: 2}
      # Last value wins during creation
      assert map == %{a: 2}
    end
  end

  describe "updating maps" do
    test "Map.put/3 adds or updates a key" do
      map = %{name: "Alice", age: 30}
      updated = Map.put(map, :age, 31)
      assert updated == %{name: "Alice", age: 31}

      with_new = Map.put(map, :city, "NYC")
      assert with_new == %{name: "Alice", age: 30, city: "NYC"}
    end

    test "update syntax with | (existing keys only)" do
      map = %{name: "Alice", age: 30}
      updated = %{map | age: 31}
      assert updated == %{name: "Alice", age: 31}
    end

    test "update syntax raises for new keys" do
      map = %{name: "Alice"}
      assert_raise KeyError, fn ->
        %{map | city: "NYC"}
      end
    end

    test "Map.merge/2 merges two maps" do
      map1 = %{a: 1, b: 2}
      map2 = %{b: 3, c: 4}
      assert Map.merge(map1, map2) == %{a: 1, b: 3, c: 4}
    end

    test "Map.delete/2" do
      map = %{a: 1, b: 2, c: 3}
      assert Map.delete(map, :b) == %{a: 1, c: 3}
    end

    test "Map.drop/2 removes multiple keys" do
      map = %{a: 1, b: 2, c: 3, d: 4}
      assert Map.drop(map, [:b, :d]) == %{a: 1, c: 3}
    end

    test "Map.update/4" do
      map = %{count: 5}
      updated = Map.update(map, :count, 0, fn current -> current + 1 end)
      assert updated == %{count: 6}

      # With default for missing key
      new = Map.update(%{}, :count, 1, fn current -> current + 1 end)
      assert new == %{count: 1}
    end
  end

  describe "Map module functions" do
    test "Map.keys/1 and Map.values/1" do
      map = %{a: 1, b: 2, c: 3}
      assert Enum.sort(Map.keys(map)) == [:a, :b, :c]
      assert Enum.sort(Map.values(map)) == [1, 2, 3]
    end

    test "Map.has_key?/2" do
      map = %{name: "Alice"}
      assert Map.has_key?(map, :name)
      refute Map.has_key?(map, :age)
    end

    test "Map.fetch/2 returns {:ok, value} or :error" do
      map = %{name: "Alice"}
      assert Map.fetch(map, :name) == {:ok, "Alice"}
      assert Map.fetch(map, :age) == :error
    end

    test "Map.fetch!/2 returns value or raises" do
      map = %{name: "Alice"}
      assert Map.fetch!(map, :name) == "Alice"
      assert_raise KeyError, fn -> Map.fetch!(map, :age) end
    end

    test "Map.get/3 with default" do
      map = %{name: "Alice"}
      assert Map.get(map, :name) == "Alice"
      assert Map.get(map, :age, 0) == 0
    end

    test "Map.to_list/1" do
      map = %{a: 1, b: 2}
      list = Map.to_list(map)
      assert Enum.sort(list) == [a: 1, b: 2]
    end

    test "creating maps from lists" do
      list = [a: 1, b: 2, c: 3]
      assert Map.new(list) == %{a: 1, b: 2, c: 3}

      # With a transformation function
      assert Map.new([1, 2, 3], fn x -> {x, x * x} end) == %{1 => 1, 2 => 4, 3 => 9}
    end
  end

  describe "nested data" do
    test "get_in for nested access" do
      data = %{user: %{name: "Alice", address: %{city: "NYC"}}}
      assert get_in(data, [:user, :name]) == "Alice"
      assert get_in(data, [:user, :address, :city]) == "NYC"
    end

    test "put_in for nested update" do
      data = %{user: %{name: "Alice", address: %{city: "NYC"}}}
      updated = put_in(data, [:user, :address, :city], "LA")
      assert get_in(updated, [:user, :address, :city]) == "LA"
    end

    test "update_in for nested update with function" do
      data = %{user: %{age: 30}}
      updated = update_in(data, [:user, :age], &(&1 + 1))
      assert get_in(updated, [:user, :age]) == 31
    end
  end
end
