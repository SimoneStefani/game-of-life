defmodule Universe do
  use GenServer

  import Enum, only: [map: 2, reduce: 3]

  # Start a generic server process for the Universe
  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end


  #######################################################
  ## Public API
  #######################################################

  # Advance the Universe to the next life state
  def tick do
    GenServer.call(__MODULE__, {:tick})
  end


  #######################################################
  ## Private Functions
  #######################################################
  
  def handle_call({:tick}, _from, []) do
    get_cells()
    |> tick_each_process
    |> wait_for_ticks
    |> reduce_ticks
    |> reap_and_sow
    {:reply, :ok, []}
  end

  # Return all the Cell processes
  defp get_cells do
    Cell.Supervisor.children
  end

  # Asynchronously advance each Cell to next state
  defp tick_each_process(processes) do
    map(processes, &(Task.async(fn -> Cell.tick(&1) end)))
  end

  # Wait for the asynchronous ticks of the Cells
  defp wait_for_ticks(processes) do
    map(asyncs, &Task.await/1)
  end

  # Build lists for Cells to be reaped and sowed
  defp reduce_ticks(ticks) do
    reduce(ticks, {[], []}, &accumulate_ticks/2)
  end

  # Accumulator helper fn
  defp accumulate_ticks({reap, sow}, {acc_reap, acc_sow}) do
    {acc_reap ++ reap, acc_sow ++ sow}
  end

  # Reap and sow Cells according to the provided lists  
  defp reap_and_sow({to_reap, to_sow}) do
    map(to_reap, &Cell.reap/1)
    map(to_sow,  &Cell.sow/1)
  end
  
end