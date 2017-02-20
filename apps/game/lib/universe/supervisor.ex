defmodule Universe.Supervisor do
  use Supervisor

  # Entry point for the application
  def start(_type, _args) do
    start_link()
  end

  # Start a supervisor for the Universe
  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  # Supervise the Universe object, the Cell supervisor and
  # the Cell registry with one_for_one strategy: if a
  # child process terminates, only that process is restarted
  def init(_) do
    children = [
      worker(Universe, []),
      supervisor(Cell.Supervisor, []),
      supervisor(Registry, [:unique, Cell.Registry])
    ]
    supervise(children, strategy: :one_for_one)
  end

end