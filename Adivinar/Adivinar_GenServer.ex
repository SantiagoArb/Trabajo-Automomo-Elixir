defmodule GameServer do
  use GenServer

  # API

  @doc """
  Inicia el servidor de juego y genera un número aleatorio.
  """
  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @doc """
  Permite que un jugador se una al servidor de juego.
  """
  def join(player_name) do
    GenServer.cast(__MODULE__, {:join, player_name})
  end

  @doc """
  Permite que un jugador envíe su intento de adivinar el número.
  """
  def send_guess(player_name, guess) do
    GenServer.cast(__MODULE__, {:guess, player_name, guess})
  end

  @doc """
  Solicita el jugador que más se acercó al número aleatorio.
  """
  def winner do
    GenServer.call(__MODULE__, :winner)
  end

  # Callbacks

  @impl true
  def init(:ok) do
    random_number = :rand.uniform(100)
    {:ok, %{players: %{}, random_number: random_number}}
  end

  @impl true
  def handle_cast({:join, player_name}, state) do
    new_players = Map.put(state.players, player_name, nil)
    {:noreply, %{state | players: new_players}}
  end

  @impl true
  def handle_cast({:guess, player_name, guess}, state) do
    new_players = Map.put(state.players, player_name, guess)
    {:noreply, %{state | players: new_players}}
  end

  @impl true
  def handle_call(:winner, _from, state) do
    winner = determine_winner(state.players, state.random_number)
    {:reply, winner, state}
  end

  # Función privada para determinar el ganador
  defp determine_winner(players, random_number) do
    players
    |> Enum.filter(fn {_player, guess} -> guess != nil end)
    |> Enum.map(fn {player, guess} -> {player, abs(random_number - guess)} end)
    |> Enum.min_by(fn {_player, distance} -> distance end)
    |> case do
      {winner, distance} -> {winner, distance, random_number}
      nil -> {:no_players, 0}
    end
  end
end

defmodule Player do
  @moduledoc """
  Módulo que representa a un jugador en el juego.
  """

  @doc """
  Inicia un proceso de jugador.
  """
  def start(name) do
    spawn(fn -> loop(name) end)
  end

  @doc false
  defp loop(name) do
    receive do
      {:send_guess, guess} ->
        GameServer.send_guess(name, guess)
        loop(name)

      {:view_winner} ->
        winner = GameServer.winner()
        IO.inspect(winner, label: "Winner")
        loop(name)

      _ ->
        IO.puts("Invalid Message")
        loop(name)
    end
  end
end

# Ejemplo de uso
# GameServer.start_link([])

# player1 = Player.start("Santiago")
# player2 = Player.start("Andrea")

# GameServer.join("Santiago")
# GameServer.join("Andrea")

# send(player1, {:send_guess, 45})
# send(player2, {:send_guess, 50})

# send(player1, {:view_winner})
