defmodule Hangman.Runtime.Server do
  @type t :: pid()
  alias Hangman.Impl.Game
  use GenServer

  # Client process

  def start_link(_arg) do
    GenServer.start_link(__MODULE__, nil)
  end

  # Server process

  def init(_arg) do
    { :ok, Game.new_game }
  end

  def handle_call({ :make_move, guess }, _from, game) do
    { updated_game, tally } = Game.make_move(game, guess)
    { :reply, tally, updated_game }
  end

  def handle_call({ :tally }, _from, game) do
    { :reply, Game.tally(game), game }
  end
end
