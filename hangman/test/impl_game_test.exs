defmodule HangmanImplGameTest do
  use ExUnit.Case
  alias Hangman.Impl.Game

  test "new game returns structure" do
    game = Game.new_game()

    assert game.turns_left == 7
    assert game.game_state == :initialising
    assert length(game.letters) > 0
  end

  test "new game returns correct word" do
    game = Game.new_game("wool")

    assert game.turns_left == 7
    assert game.game_state == :initialising
    assert game.letters == ["w", "o", "o", "l"]
  end

  test "game won or lost returns same state" do
    for state <- [:won, :lost] do
      game = Game.new_game()
      game = Map.put(game, :game_state, state)
      {return_game, _tally} = Game.make_move(game, "z")
      assert game == return_game
    end
  end

  test "duplicate letter" do
    game = Game.new_game()
    {game, _tally} = Game.make_move(game, "a")
    assert game.game_state != :already_used
    {game, _tally} = Game.make_move(game, "b")
    assert game.game_state != :already_used
    {game, _tally} = Game.make_move(game, "a")
    assert game.game_state == :already_used
  end

  test "recording inputs" do
    game = Game.new_game()
    {game, _tally} = Game.make_move(game, "a")
    {game, _tally} = Game.make_move(game, "b")
    {game, _tally} = Game.make_move(game, "c")
    assert MapSet.equal?(game.used, MapSet.new(["a", "b", "c"]))
  end

  test "we recognise a letter in a word" do
    game = Game.new_game("hello")
    {game, tally} = Game.make_move(game, "h")
    assert tally.game_state == :good_guess
    {_game, tally} = Game.make_move(game, "l")
    assert tally.game_state == :good_guess
  end

  test "we recognise a letter not in a word" do
    game = Game.new_game("hello")
    {game, tally} = Game.make_move(game, "a")
    assert tally.game_state == :bad_guess
    assert tally.turns_left == 6
    {game, tally} = Game.make_move(game, "l")
    assert tally.game_state == :good_guess
    {game, tally} = Game.make_move(game, "y")
    assert tally.game_state == :bad_guess
    assert tally.turns_left == 5
  end

  test "can handle a sequence of moves" do
    [
      # guess state    turns left   letters          letters used
      ["a", :bad_guess, 6, ["_", "_", "_", "_", "_"], ["a"]],
      ["a", :already_used, 6, ["_", "_", "_", "_", "_"], ["a"]],
      ["e", :good_guess, 6, ["_", "e", "_", "_", "_"], ["a", "e"]],
      ["x", :bad_guess, 5, ["_", "e", "_", "_", "_"], ["a", "e", "x"]]
    ]
    |> test_sequence_of_moves
  end

  test "can handle a winning game" do
    [
      # guess state    turns left   letters          letters used
      ["a", :bad_guess, 6, ["_", "_", "_", "_", "_"], ["a"]],
      ["a", :already_used, 6, ["_", "_", "_", "_", "_"], ["a"]],
      ["e", :good_guess, 6, ["_", "e", "_", "_", "_"], ["a", "e"]],
      ["x", :bad_guess, 5, ["_", "e", "_", "_", "_"], ["a", "e", "x"]],
      ["l", :good_guess, 5, ["_", "e", "l", "l", "_"], ["a", "e", "l", "x" ]],
      ["h", :good_guess, 5, ["h", "e", "l", "l", "_"], ["a", "e", "h", "l", "x"]],
      ["o", :won, 5, ["h", "e", "l", "l", "o"], ["a", "e", "h", "l", "o", "x"]]
    ]
    |> test_sequence_of_moves
  end

  test "can handle a losing game" do
    [
      # guess state    turns left   letters          letters used
      ["a", :bad_guess, 6, ["_", "_", "_", "_", "_"], ["a"]],
      ["b", :bad_guess, 5, ["_", "_", "_", "_", "_"], ["a", "b"]],
      ["c", :bad_guess, 4, ["_", "_", "_", "_", "_"], ["a", "b", "c"]],
      ["d", :bad_guess, 3, ["_", "_", "_", "_", "_"], ["a", "b", "c", "d"]],
      ["f", :bad_guess, 2, ["_", "_", "_", "_", "_"], ["a", "b", "c", "d", "f"]],
      ["g", :bad_guess, 1, ["_", "_", "_", "_", "_"], ["a", "b", "c", "d", "f", "g"]],
      ["i", :lost, 0, ["_", "_", "_", "_", "_"], ["a", "b", "c", "d", "f", "g", "i"]],
    ]
    |> test_sequence_of_moves
  end

  def test_sequence_of_moves(script) do
    game = Game.new_game("hello")
    Enum.reduce(script, game, &check_one_move/2)
  end

  defp check_one_move([guess, state, turns_left, letters, used], game) do
    {game, tally} = Game.make_move(game, guess)
    assert tally.game_state == state
    assert tally.turns_left == turns_left
    assert tally.letters == letters
    assert tally.used == used
    game
  end
end
