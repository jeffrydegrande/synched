defmodule Synched.PageController do
  use Synched.Web, :controller
  require Logger

  def index(conn, params) do
    wait = Map.get(params, "wait", "0")
    result = Synched.exec("Hello World", fn ->
      IO.puts "Running the code with " <> wait
      :timer.sleep(500 * String.to_integer(wait))
      "got it: " <> wait
    end)

    json conn, result
  end
end
