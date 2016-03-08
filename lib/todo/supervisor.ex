defmodule Todo.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, nil)
  end

  def init(_) do
    supervise(processes, strategy: :one_for_one)
  end

  defp processes do
    [
      worker(Todo.ProcessRegistry, []),
      supervisor(Todo.Database, ["./persist"]),
      worker(Todo.Cache, [])
    ]
  end
end
