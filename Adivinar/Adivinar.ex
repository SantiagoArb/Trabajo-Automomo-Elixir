defmodule GameServer do
  @moduledoc """
  Módulo que representa un servidor de juego que maneja jugadores y sus intentos.
  """

  @doc """
  Inicia el servidor de juego y genera un número aleatorio.
  random_number Genera un número aleatorio entre 1 y 100
  """
  def start do
    random_number = :rand.uniform(100)
    spawn(fn -> loop(%{}, random_number) end)
  end

  @doc """
  Permite que un jugador se una al servidor de juego.

  ## Parámetros
  - `server_pid`: PID del proceso del servidor.
  - `player_name`: Nombre del jugador que se va a unir.
  """
  def join(server_pid, player_name) do
    send(server_pid, {:join, player_name, self()})
  end

  @doc """
  Permite que un jugador envíe su intento de adivinar el número.

  ## Parámetros
  - `server_pid`: PID del proceso del servidor.
  - `player_name`: Nombre del jugador que envía su intento.
  - `guess`: Intento del jugador.
  """
  def send_guess(server_pid, player_name, guess) do
    send(server_pid, {:guess, player_name, guess})
  end

  @doc """
  Solicita el jugador que más se acercó al número aleatorio.

  ## Parámetros
  - `server_pid`: PID del proceso del servidor.

  ## Retorno
  - Devuelve el nombre del jugador más cercano y la distancia.
  """
  def winner(server_pid) do
    send(server_pid, {:winner, self()})

    receive do
      {:response, winner} -> winner
    end
  end

  @doc false
  defp loop(state, random_number) do
    new_state =
      receive do
        {:join, player_name, player_pid} ->
          send(player_pid, {:joined, player_name})
          Map.put(state, player_name, nil)

        {:guess, player_name, guess} ->
          Map.put(state, player_name, guess)

        {:winner, caller_pid} ->
          winner = determine_winner(state, random_number)
          send(caller_pid, {:response, winner})
          state

        _ ->
          IO.puts("Invalid Message")
          state
      end

    loop(new_state, random_number)
  end
 @doc """
  Determina que jugador se acerco mas al numero aleatorio y renorta el nombre del ganador, los numeros de diferencia del numero aleatorio y el numero aleatorio

  ## Parámetros
  - `server_pid`: PID del proceso del servidor.
  - `player_name`: Nombre del jugador que se va a unir.
  """
  defp determine_winner(state, random_number) do
    state
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

  ## Parámetros
  - `name`: Nombre del jugador.
  - `server_pid`: PID del proceso del servidor de juego.
  """
  def start(name, server_pid) do
    spawn(fn -> loop(name, server_pid) end)
  end

  @doc false
  defp loop(name, server_pid) do
    receive do
      {:joined, player_name} ->
        IO.puts("#{player_name} has joined the game!")
        loop(name, server_pid)

      {:send_guess, guess} ->
        GameServer.send_guess(server_pid, name, guess)
        loop(name, server_pid)

      {:view_winner} ->
        winner = GameServer.winner(server_pid)
        IO.inspect(winner, label: "Winner")
        loop(name, server_pid)

      _ ->
        IO.puts("Invalid Message")
        loop(name, server_pid)
    end
  end
end

# Ejemplo de uso
# server_pid = GameServer.start()

# player1 = Player.start("Santiago", server_pid)
# player2 = Player.start("Andrea", server_pid)

# GameServer.join(server_pid, "Santiago")
# GameServer.join(server_pid, "Andrea")

# send(player1, {:send_guess, 45})
# send(player2, {:send_guess, 50})

# send(player1, {:view_winner})
