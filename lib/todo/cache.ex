defmodule Todo.Cache do
  use GenServer

  def start_link do
    IO.puts("Starting cache")
    GenServer.start(__MODULE__, nil, name: :todo_cache)
  end

  def server_process(todo_list_name) do
    GenServer.call(:todo_cache, {:server_process, todo_list_name})
  end

  def init(_) do
    {:ok, Map.new}
  end

  def handle_call({:server_process, todo_list_name}, _, todo_servers) do
    case Map.fetch(todo_servers, todo_list_name) do
      {:ok, todo_server} ->
        {:reply, todo_server, todo_servers}

      :error ->
        {:ok, new_server} = Todo.Server.start_link(todo_list_name)
        servers = Map.put(todo_servers, todo_list_name, new_server)

        {:reply, new_server, servers}
    end
  end
end
