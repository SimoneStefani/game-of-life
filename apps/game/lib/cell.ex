defmodule Cell do
  use GenServer

  import Enum, only: [map: 2, filter: 2]

  @offsets [
    {-1, -1}, { 0, -1}, { 1, -1}, {-1,  0}, 
    { 1,  0}, {-1,  1}, { 0,  1}, { 1,  1}
  ]

  # Start a generic server process for the Cell. The process 
  # is named according to the position with a Registry as index
  def start_link(position) do
    GenServer.start_link(__MODULE__, position, name: {
      :via, Registry, {Cell.Registry, position}
    })
  end


  #######################################################
  ## Public API
  #######################################################

  # Remove a Cell from the Universe
  def reap(process) do
    Supervisor.terminate_child(Cell.Supervisor, process)
  end

  # Add a Cell to the universe in a specific position
  def sow(position) do
    Supervisor.start_child(Cell.Supervisor, [position])
  end

  # Advance to the next state of the Cell
  def tick(process) do
    GenServer.call(process, {:tick})
  end

  # Return the position of a Cell
  def position(process) do
    GenServer.call(process, {:position})
  end

  # Return the number of neighbours of a Cell
  def count_neighbours(process) do
    GenServer.call(process, {:count_neighbours})
  end

  # Translate the Cell position {x, y} into the process
  # ID if the Cell is alive (avoid ghost neighbours)
  def lookup(position) do
    Cell.Registry
    |> Registry.lookup(position)
    |> Enum.map(fn
      {pid, _valid} -> pid
      nil -> nil
    end)
    |> Enum.filter(&Process.alive?/1)
    |> List.first
  end


  #######################################################
  ## Private Functions
  #######################################################

  # Determine if the current Cell needs to be reaped and
  # the list of neighbouring Cells to sow
  def handle_call({:tick}, _from, position) do
    to_reap = position
    |> do_count_neighbours
    |> case do
         2 -> []
         3 -> []
         _ -> [self()]
       end

    to_sow = position
    |> neighbouring_positions
    |> keep_dead
    |> keep_valid_children

    {:reply, {to_reap, to_sow}, position}
  end

  # Return position of a Cell
  def handle_call({:position}, _from, position) do
    {:reply, position, position}
  end

  # Return the number of neighbours of a Cell
  def handle_call({:count_neighbours}, _from, position) do
    {:reply, do_count_neighbours(position), position}
  end

  # Count the living neighbours of a Cell
  defp do_count_neighbours(position) do
    position
    |> neighbouring_positions
    |> keep_live
    |> length
  end

  # Compute the coordinates of the eight neighbouring
  # positions of a Cell at {x, y}
  defp neighbouring_positions({x, y}) do
    @offsets
    |> map(fn {dx, dy} -> {x + dx, y + dy} end)
  end

  # Determine which Cells to are alive
  defp keep_live(positions) do
    filter(positions, &(lookup(&1) != nil))
  end

  # Determine which Cells to are dead
  defp keep_dead(positions) do
    filter(positions, &(lookup(&1) == nil))
  end

  # Determine dead positions with three neighbours
  defp keep_valid_children(positions) do
    positions
    |> filter(&(do_count_neighbours(&1) == 3))
  end

end