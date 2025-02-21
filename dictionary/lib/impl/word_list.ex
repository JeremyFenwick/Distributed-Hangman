defmodule Dictionary.Impl.WordList do
  @type t :: list(String.t())

  def word_list() do
    "assets/words"
    |> File.read!
    |> String.split("\n", trim: true)
  end

  def random_word(word_list) do
    word_list
    |> Enum.random
  end
end
