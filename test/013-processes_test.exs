ExUnit.start()

defmodule ProcessesTest do
  use ExUnit.Case, async: true

  # =============================================================
  # 013 - Processes
  # Elixir runs on the BEAM VM. Processes are lightweight,
  # isolated, and communicate via message passing.
  # This is the foundation of Elixir's concurrency model.
  # =============================================================

  describe "spawning processes" do
    test "spawn creates a new process" do
      pid = spawn(fn -> 1 + 1 end)
      assert is_pid(pid)
    end

    test "self() returns the current process PID" do
      pid = self()
      assert is_pid(pid)
    end

    test "Process.alive?/1 checks if a process is running" do
      pid = spawn(fn -> :timer.sleep(1000) end)
      assert Process.alive?(pid)

      pid2 = spawn(fn -> :ok end)
      :timer.sleep(50)  # wait for it to finish
      refute Process.alive?(pid2)
    end
  end

  describe "message passing" do
    test "send and receive messages" do
      # Send a message to the current process
      send(self(), {:hello, "world"})

      # Receive the message
      result = receive do
        {:hello, msg} -> msg
      end

      assert result == "world"
    end

    test "receive with timeout" do
      result = receive do
        {:hello, msg} -> msg
      after
        100 -> "timeout"
      end

      assert result == "timeout"
    end

    test "send between processes" do
      parent = self()

      spawn(fn ->
        send(parent, {:result, 42})
      end)

      result = receive do
        {:result, value} -> value
      after
        1000 -> :timeout
      end

      assert result == 42
    end

    test "messages are pattern matched in order" do
      send(self(), :first)
      send(self(), :second)
      send(self(), :third)

      assert receive(do: (msg -> msg)) == :first
      assert receive(do: (msg -> msg)) == :second
      assert receive(do: (msg -> msg)) == :third
    end

    test "selective receive" do
      send(self(), {:a, 1})
      send(self(), {:b, 2})
      send(self(), {:a, 3})

      # Can match specific patterns out of order
      result = receive do
        {:b, value} -> value
      end
      assert result == 2
    end
  end

  describe "spawn_link and process monitoring" do
    test "spawn_link links processes together" do
      # If a linked process crashes, the parent also crashes
      # unless it traps exits
      Process.flag(:trap_exit, true)

      pid = spawn_link(fn -> exit(:normal) end)

      result = receive do
        {:EXIT, ^pid, reason} -> reason
      after
        1000 -> :timeout
      end

      assert result == :normal
    end

    test "trap_exit catches linked process crashes" do
      Process.flag(:trap_exit, true)

      pid = spawn_link(fn -> raise "oops" end)

      result = receive do
        {:EXIT, ^pid, {%RuntimeError{message: msg}, _stack}} -> msg
      after
        1000 -> :timeout
      end

      assert result == "oops"
    end

    test "Process.monitor for one-way monitoring" do
      pid = spawn(fn -> :timer.sleep(50) end)
      ref = Process.monitor(pid)

      result = receive do
        {:DOWN, ^ref, :process, ^pid, reason} -> reason
      after
        1000 -> :timeout
      end

      # Process exits normally
      assert result == :normal
    end
  end

  describe "stateful processes (basic server)" do
    defmodule Counter do
      def start(initial_value \\ 0) do
        spawn(fn -> loop(initial_value) end)
      end

      defp loop(count) do
        receive do
          {:get, caller} ->
            send(caller, {:count, count})
            loop(count)

          {:increment, amount} ->
            loop(count + amount)

          :stop ->
            :ok  # exit the loop
        end
      end
    end

    test "stateful process with message passing" do
      pid = Counter.start(0)

      # Increment
      send(pid, {:increment, 1})
      send(pid, {:increment, 5})

      # Get current value
      send(pid, {:get, self()})

      result = receive do
        {:count, value} -> value
      after
        1000 -> :timeout
      end

      assert result == 6

      # Stop
      send(pid, :stop)
      :timer.sleep(50)
      refute Process.alive?(pid)
    end
  end

  describe "Task module (higher-level concurrency)" do
    test "Task.async and Task.await" do
      task = Task.async(fn ->
        :timer.sleep(50)
        42
      end)

      # Do other work here...

      result = Task.await(task)
      assert result == 42
    end

    test "running multiple tasks in parallel" do
      tasks = Enum.map(1..5, fn i ->
        Task.async(fn -> i * i end)
      end)

      results = Task.await_many(tasks)
      assert results == [1, 4, 9, 16, 25]
    end

    test "Task.yield for non-blocking check" do
      task = Task.async(fn ->
        :timer.sleep(200)
        42
      end)

      # Check immediately - not ready yet
      assert Task.yield(task, 0) == nil

      # Wait for it
      assert Task.yield(task, 1000) == {:ok, 42}
    end
  end

  describe "Agent (simple state management)" do
    test "Agent stores and retrieves state" do
      {:ok, agent} = Agent.start_link(fn -> [] end)

      # Add items
      Agent.update(agent, fn list -> ["hello" | list] end)
      Agent.update(agent, fn list -> ["world" | list] end)

      # Get state
      result = Agent.get(agent, fn list -> list end)
      assert result == ["world", "hello"]

      Agent.stop(agent)
    end

    test "Agent.get_and_update" do
      {:ok, agent} = Agent.start_link(fn -> 0 end)

      # Get current value and update at the same time
      old_value = Agent.get_and_update(agent, fn state ->
        {state, state + 1}
      end)

      assert old_value == 0
      assert Agent.get(agent, & &1) == 1

      Agent.stop(agent)
    end
  end

  describe "process registry" do
    test "registering a process by name" do
      pid = spawn(fn ->
        receive do
          :stop -> :ok
        end
      end)

      Process.register(pid, :my_process)
      assert Process.whereis(:my_process) == pid

      send(:my_process, :stop)
      :timer.sleep(50)
      assert Process.whereis(:my_process) == nil
    end
  end

  describe "process dictionary (use sparingly)" do
    test "process dictionary is per-process mutable state" do
      # Generally discouraged, but useful to know about
      Process.put(:key, "value")
      assert Process.get(:key) == "value"

      Process.put(:key, "new_value")
      assert Process.get(:key) == "new_value"

      Process.delete(:key)
      assert Process.get(:key) == nil
    end
  end
end
