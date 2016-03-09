defmodule Todo.ProcessRegistry do
  use GenServer

  import Kernel, except: [send: 2]

  def start_link do
    IO.puts "Starting process registry"
    GenServer.start_link(__MODULE__, nil, name: :process_registry)
  end

  def register_name(key, pid) do
    GenServer.call(:process_registry, {:register_name, key, pid})
  end

  def unregister_name(key) do
    GenServer.call(:process_registry, {:unregister_name, key})
  end

  def whereis_name(key) do
    case :ets.lookup(:todo_process_registry, key) do
      [{^key, pid}] -> pid
      _ -> :undefined
    end
  end

  def send(key, message) do
    case whereis_name(key) do
      :undefined ->
        {:badarg, {key, message}}
      pid ->
        Kernel.send(pid, message)
        pid
    end
  end

  def init(_) do
    :ets.new(:todo_process_registry, [:named_table, :protected, :set])
    {:ok, nil}
  end

  def handle_call({:register_name, key, pid}, _caller, state) do
    case whereis_name(key) do
      :undefined ->
        Process.monitor(pid)
        :ets.insert(:todo_process_registry, {key, pid})
        {:reply, :yes, state}

      _ -> {:reply, :no, state}
    end
  end

  def handle_call(:process_registry, {:unregister_name, key}, _caller, state) do
    :ets.delete(:todo_process_registry, key)
    {:noreply, state}
  end

  def handle_info({:DOWN, _, :process, terminated_pid, _}, state) do
    :ets.match_delete(:todo_process_registry, {:_, terminated_pid})
    {:noreply, state}
  end
end
