defmodule Synched.PageController do
  use Synched.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
