defmodule Todo.Server do
  use GenServer

  def start(name) do
    GenServer.start(__MODULE__, name)
  end

  def init(name) do
    {:ok, {name, Todo.List.new}}
  end

  def handle_cast({:add_entry, new_entry}, {name, todo_list}) do
    new_state = Todo.List.add_entry(todo_list, new_entry)
    Todo.Database.store(name, new_state)
    {:noreply, {name, new_state}}
  end

  def handle_call({:entries, date}, _, todo_list) do
    {:reply, Todo.List.entries(todo_list, date), todo_list}
  end

  def add_entry(pid, new_entry) do
    GenServer.cast(pid, {:add_entry, new_entry})
  end

  def entries(pid, date) do
    GenServer.call(pid, {:entries, date})
  end
end


