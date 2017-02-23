defmodule Pattern do

  def glider(x, y) do
    [
      {1, 2},
      {2, 1},
      {0, 0}, {1, 0}, {2, 0},
    ]
    |> Enum.map(fn
      {cx, cy} -> {x + cx, y + cy}
    end)
  end

  def diehard(x, y) do
    [
                                                      {6, 2},
      {0, 1}, {1, 1},
              {1, 0},                         {5, 0}, {6, 0}, {7, 0},
    ]
    |> Enum.map(fn
      {cx, cy} -> {x + cx, y + cy}
    end)
  end

  def tumbler(x, y) do
    [
      {1,0}, {7,0},
      {0,1}, {2,1}, {6,1}, {8,1},
      {0,2}, {3,2}, {5,2}, {8,2},
      {2,3}, {6,3},
      {2,4}, {3,4}, {5,4}, {6,4}
    ]
    |> Enum.map(fn
      {cx, cy} -> {x + cx, y + cy}
    end)
  end

  def eight(x, y) do
    [
      {2,0},
      {1,1}, {3,1},
      {0,2}, {2,2}, {4,2},
      {1,3}, {3,3}, {5,3},
      {2,4}, {4,4}, {6,4},
      {3,5}, {5,5}, {7,5},
      {4,6}, {6,6},
      {5,7}
    ]
    |> Enum.map(fn
      {cx, cy} -> {x + cx, y + cy}
    end)
  end

end