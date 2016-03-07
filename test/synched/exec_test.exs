defmodule Synched.ExecTest do
  use ExUnit.Case, async: true

  test "it caches the function" do
    assert Synched.exec( "foobar", fn -> "foo" end) == "foo"
    assert Synched.exec( "foobar", fn -> flunk "Shouldn't be called"  end) == "foo"
  end
end
