defmodule TextClient.Impl.Player do
  @typep game :: Hangman.game
  @typep tally :: Hangman.Type.tally
  @typep state :: { game, tally }

  @spec start() :: :ok
  def start() do
    game = Hangman.new_game()
    tally = Hangman.tally(game)
    interact( {game, tally})
  end

  #################################################

  #   @type state :: :initialising | :won | :lost | :good_guess | :bad_guess | :already_used

  @spec interact(state) :: :ok
  def interact({_game, _tally = %{ game_state: :won }}), do:
  IO.puts("Congratulations. You win!")

  def interact({_game, tally = %{ game_state: :lost }}), do:
  IO.puts("Sorry, you lost... the word was #{ tally.letters |> Enum.join}")

  def interact({ game, tally }) do
    IO.puts feedback_for(tally)
    IO.puts current_word(tally)
    Hangman.make_move(game, get_guess())
    |> interact
  end

  #################################################

  def feedback_for(tally = %{ game_state: :initialising }) do
    "Welcome! I'm thinking of a #{tally.letters |> length } letter word."
  end

  #################################################

  def feedback_for(%{ game_state: :good_guess }), do: "Good guess."
  def feedback_for(%{ game_state: :bad_guess }), do: "Bad guess, try again!"
  def feedback_for(%{ game_state: :already_used }), do: "You already picked that letter. Guess again."

  #################################################

  def current_word(tally) do
    [
      "Word so far: ", tally.letters |> Enum.join(" "),
      " turns left: ", tally.turns_left |> to_string,
      " turns used: ", tally.used |> Enum.join(",")
    ]
  end

  #################################################

  def get_guess() do
    IO.gets("Guess the letter: ")
    |> String.trim()
    |> String.downcase
    |> validate_guess
  end

  #################################################

  defp validate_guess(<<char::binary-size(1)>>) when char in ~w(a b c d e f g h i j k l m n o p q r s t u v w x y z) do
    char
  end

  defp validate_guess(_invalid_guess) do
    IO.puts("Invalid input. Please enter a single letter.")
    get_guess()
  end
end
