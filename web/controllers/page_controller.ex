defmodule Synched.PageController do
  use Synched.Web, :controller
  require Logger

  def index(conn, _params) do
    json conn, Synched.exec("Hello World", fn -> "got it" end)
  end
end
