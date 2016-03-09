defmodule Todo.Server do
  use GenServer

  def start_link(name) do
    IO.puts "Starting todo server for #{name}"
    GenServer.start_link(__MODULE__, name, name: via_tuple(name))
  end

  def init(name) do
    todo_list = Todo.Database.get(name) || Todo.List.new
    {:ok, {name, todo_list}}
  end

  def handle_cast({:add_entry, new_entry}, {name, todo_list}) do
    todo_list = Todo.List.add_entry(todo_list, new_entry)
    Todo.Database.store(name, todo_list)
    {:noreply, {name, todo_list}}
  end

  def handle_cast(:clear, {name, todo_list}) do
    list = Todo.List.new
    Todo.Database.store(name, list)
    {:noreply, {name, list}}
  end

  def handle_call({:entries, date}, _, {name, todo_list}) do
    {:reply, Todo.List.entries(todo_list, date), todo_list}
  end

  def add_entry(pid, new_entry) do
    GenServer.cast(pid, {:add_entry, new_entry})
  end

  def clear(pid) do
    GenServer.cast(pid, :clear)
  end

  def entries(pid, date) do
    GenServer.call(pid, {:entries, date})
  end

  def whereis(name) do
    Todo.ProcessRegistry.whereis_name({:todo_server, name})
  end

  def via_tuple(name) do
    {:via, Todo.ProcessRegistry, {:todo_server, name}}
  end
end
