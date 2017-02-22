# Conway's Game of Life
### *A concurrent implementation in Elixir*


### 1. Introduction
The game of life is the best-known two-dimensional cellular automaton, invented by John H. Conway and popularised in Martin Gardner's Scientific American column starting in October 1970.

The life cellular automaton is run by placing a number of filled cells on a two-dimensional grid. Each generation then switches cells on or off depending on the state of the cells that surround them. The rules are defined as follows. All eight of the cells surrounding the current one are checked to see if they are on or not. The cells that are on are counted and this count is then used to determine what will happen to the current cell.

1. **Death:** if the count is less than 2 or greater than 3, the current cell is switched off.

2. **Survival:** if the count is exactly 2, or the count is exactly 3 and the current cell is on, the current cell is left unchanged.

3. **Birth:** if the current cell is off and the count is exactly 3, the current cell is switched on.

*(from http://mathworld.wolfram.com/GameofLife.html)*

### 2. The OTP architecture
The following drawing describe the architecture of the Elixir app that contains the game:
<p align="center"><img src="https://github.com/SimoneStefani/game-of-life/blob/master/assets/supervision_tree.png"></p>

Each cell is represented by a `GenServer` process and they are all controlled by the `Cell.Supervisor` with a strategy *simple_one_for_one* which informs the system that cells will be added and removed dynamically.
The `Universe.Supervisor` controls the `Universe` together with the `Cell.Supervisor` and the `Registry`. The Universe describes the overall state of the game and can be *ticked* in order to advance to the next state. The Registry is a key-value storage structure and provides a comfortable way to link each Cell PID with a key which is its postion in the form `{x, y}`.

### 3. The bigger picture
In order to provide a *front-end* for the game, a Phoenix app `interface` has been created and added together with the `game` Elixir app under the `game_of_life` Elixir **umbrella** app. This allows the two apps to live independently but at the same time to easily communicate. The communication between the two apps is provided by the Phoenix Channels based on websockets.
<p align="center"><img src="https://github.com/SimoneStefani/game-of-life/blob/master/assets/umbrella_app.png"></p>
The web interface, developed in VueJS, send *tick* messages to the Elixir `game` app which advances the state of the game and responds with the new configuration of the Universe.
