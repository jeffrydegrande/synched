defmodule Synched.PageControllerTest do
  use Synched.ConnCase

  test "GET /" do
    conn = get conn(), "/"
    assert json_response(conn, 200) =~ "got it"
  end
end
