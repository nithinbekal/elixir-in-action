defmodule Todo.Database do
  use GenServer

  def start_link(db_folder) do
    GenServer.start(__MODULE__, db_folder, name: :database_server)
  end

  def store(key, data) do
    choose_worker(key)
    |> Todo.DatabaseWorker.store(key, data)
  end

  def get(key) do
    choose_worker(key)
    |> Todo.DatabaseWorker.get(key)
  end

  def init(db_folder) do
    workers = start_workers(db_folder)
    {:ok, workers}
  end

  def handle_call({:choose_worker, key}, _from, workers) do
    worker_id = :erlang.phash2(key, 3)
    worker = HashDict.get(workers, worker_id)
    {:reply, worker, workers}
  end

  defp choose_worker(key) do
    GenServer.call(:database_server, {:choose_worker, key})
  end

  defp start_workers(db_folder) do
    for index <- 1..3, into: HashDict.new do
      {:ok, pid} = Todo.DatabaseWorker.start_link(db_folder)
      {index-1, pid}
    end
  end
end
