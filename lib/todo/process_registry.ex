defmodule Todo.ProcessRegistry do
  use GenServer

  import Kernel, except: [send: 2]

  def start_link do
    IO.puts "Starting process registry"
    GenServer.start_link(__MODULE__, nil, name: :process_registry)
  end

  def init(_) do
    {:ok, Map.new}
  end

  def register_name(key, pid) do
    GenServer.call(:process_registry, {:register_name, key, pid})
  end

  def unregister_name(key) do
    GenServer.call(:process_registry, {:unregister_name, key})
  end

  def whereis_name(key) do
    GenServer.call(:process_registry, {:whereis_name, key})
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

  def handle_call({:register_name, key, pid}, _caller, process_registry) do
    case Map.get(process_registry, key) do
      nil ->
        Process.monitor(pid)
        new_registry = Map.put(process_registry, key, pid)

        {:reply, :yes, new_registry}

      _ ->
        {:reply, :no, process_registry}
    end
  end

  def handle_call({:whereis_name, key}, _caller, process_registry) do
    name = Map.get(process_registry, key, :undefined)
    {:reply, name, process_registry}
  end

  def handle_info({:DOWN, _, :process, pid, _}, process_registry) do
    {:noreply, deregister_pid(process_registry, pid)}
  end

  def deregister_pid(process_registry, pid) do
    Enum.reduce(
      process_registry,
      process_registry,
      fn
        ({reg_alias, proc}, acc) when proc == pid ->
          Map.delete(acc, reg_alias)

        (_any, acc) ->
          acc
      end
    )
  end
end
