defmodule Synched.ExecTest do
  use ExUnit.Case, async: true

  test "it caches the function" do
    assert Synched.exec( "foobar", fn -> "foo" end) == "foo"
    assert Synched.exec( "foobar", fn -> "notfoo" end) == "foo"
  end

  test "it waits for the result of the first call" do
    assert Synched.exec( "2nd test", fn ->
      :timer.sleep(2000)
      "foo"
    end) == "foo"

    assert Synched.exec( "2nd test", fn ->
      flunk "this shouldn't be called"
    end) == "foo"
  end
end
