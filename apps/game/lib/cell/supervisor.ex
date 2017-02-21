defmodule Cell.Supervisor do
  use Supervisor

  # Start a supervisor for the Cells
  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  # Supervise the Cell objects with simple_one_for_one strategy:
  # the supervisor informs the system that we’ll be dynamically 
  # adding and removing children from this supervision tree.
  # Transient restart means that, if the child process exits due to a :normal, 
  # :shutdown, or {:shutdown, term} reason, it won’t be restarted
  def init([]) do
    children = [
      worker(Cell, [])
    ]
    supervise(children, strategy: :simple_one_for_one, restart: :transient)
  end

  # Return the PIDs of the children processes
  def children do
    Cell.Supervisor
    |> Supervisor.which_children
    |> Enum.map(fn {_, pid, _, _} -> pid end)
  end

  # Return the positions {x: a, y: b} of the children processes
  def positions do
    coord = children()
    |> Enum.map(&Cell.position/1)

    num = children()
    |> Enum.map(&Cell.count_neighbours/1)
  
    Enum.zip(coord, num)
    |> Enum.map(fn {{x, y}, n} -> %{x: x, y: y, n: n} end)
  end

end