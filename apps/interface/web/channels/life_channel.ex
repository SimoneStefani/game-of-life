defmodule Interface.LifeChannel do
  use Phoenix.Channel

  # Join channel handler and clear the Universe
  def join("life", _, socket) do
    Cell.Supervisor.children
    |> Enum.map(&Cell.reap/1)

    {:ok, socket}
  end

  # Clear the Universe, sow a pattern of Cells and 
  # return living positions  
  def handle_in("reset", _, socket) do
    Cell.Supervisor.children
    |> Enum.map(&Cell.reap/1)
    
    Pattern.diehard(30, 30)
    |> Enum.map(&Cell.sow/1)

    broadcast!(socket, "reset", %{positions: Cell.Supervisor.positions})
    {:noreply, socket}
  end

  # When "tick" message is received advance the Universe
  # to the next state and broadcast the Cells' positions
  def handle_in("tick", _, socket) do
    Universe.tick

    broadcast!(socket, "tick", %{positions: Cell.Supervisor.positions})
    {:noreply, socket}
  end
  
end