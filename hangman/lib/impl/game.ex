defmodule Hangman.Impl.Game do
  alias Hangman.Type

  @type t :: %Hangman.Impl.Game{
          turns_left: integer(),
          game_state: Type.state(),
          letters: list(String.t()),
          used: MapSet.t(String.t())
        }

  defstruct(
    turns_left: 7,
    game_state: :initialising,
    letters: [],
    used: MapSet.new()
  )

  #################################################

  def new_game do
    new_game(Dictionary.random_word())
  end

  def new_game(word) do
    %__MODULE__{
      letters: word |> String.codepoints()
    }
  end

  #################################################

  def make_move(%{game_state: state} = game, _guess)
      when state in [:won, :lost],
      do: game |> return_with_tally()

  def make_move(game, guess) do
    accept_guess(game, guess, MapSet.member?(game.used, guess))
    |> return_with_tally()
  end

  #################################################

  def tally(game) do
    %{
      turns_left: game.turns_left,
      game_state: game.game_state,
      letters: reveal_guessed_letters(game),
      used: game.used |> MapSet.to_list() |> Enum.sort()
    }
  end

  #################################################

  defp accept_guess(game, _guess, _already_used = true) do
    %{game | game_state: :already_used}
  end

  defp accept_guess(game, guess, _already_used = false) do
    %{game | used: MapSet.put(game.used, guess)}
    |> score_guess(Enum.member?(game.letters, guess))
  end

  #################################################

  defp return_with_tally(game) do
    {game, tally(game)}
  end

  #################################################

  # Guessed all letters? -> :won | :good_guess
  defp score_guess(game, _good_guess = true) do
    new_state = maybe_won(MapSet.subset?(MapSet.new(game.letters), game.used))
    %{game | game_state: new_state}
  end

  # If turns_left == 1 -> lost | dec turns_left, :bad_guess
  defp score_guess(game = %{turns_left: 1}, _bad_guess = false) do
    %{game | game_state: :lost, turns_left: 0 }
  end

  defp score_guess(game, _bad_guess = false) do
    %{game | turns_left: game.turns_left - 1, game_state: :bad_guess}
  end

  #################################################

  defp maybe_won(true), do: :won
  defp maybe_won(_), do: :good_guess

  #################################################

  defp reveal_guessed_letters(%{ game_state: :lost } = game ), do: game.letters
  defp reveal_guessed_letters(game) do
    game.letters
    |> Enum.map(fn letter -> MapSet.member?(game.used, letter) |> maybe_reveal(letter) end)
  end

  #################################################

  defp maybe_reveal(true, letter), do: letter
  defp maybe_reveal(false, _letter), do: "_"
end
