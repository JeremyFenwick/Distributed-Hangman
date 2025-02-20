defmodule Dictionary do
  alias Dictionary.Impl.WordList
  @opaque t :: WordList.t

  @spec start() :: t
  def start(), do: WordList.word_list("assets/words")

  @spec random_word(list(String.t())) :: String.t()
  defdelegate random_word(words), to: WordList
end
