defmodule TextClient.Runtime.RemoteHangman do
  @remote_server :"hangman@madvillain-ub"

  def connect() do
    :rpc.call(@remote_server, Hangman, :new_game, [])
  end
end
