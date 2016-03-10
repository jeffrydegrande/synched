defmodule Synched.ExecTest do
  use ExUnit.Case, async: true

  test "it maintains the initial value", %{test: test} do
    assert Synched.exec(test, fn -> 1 end, 20) == 1

    parent = self()
    (1..5)
    |> Enum.map(fn x ->
      spawn(
        fn ->
          Synched.exec(test, fn -> send(parent, {:error, x}) end)
          send(parent, :ok)
        end
      )
    end)
    |> Enum.map(fn _pid ->
      receive do
        {:error, x} -> flunk("wrong function called: " <> Integer.to_string(x))
        :ok -> true
      end
    end)
  end

  test "it updates it's value after ttl", %{test: test} do

    some_random_value = fn -> :random.uniform(100) end

    first_value = Synched.exec(test, some_random_value, 20)
    assert first_value != :no_value

    assert Synched.exec(test, fn -> 101 end, 20) == first_value
    :timer.sleep(40)

    assert Synched.exec(test, fn -> 101 end, 20) != first_value
  end
end
