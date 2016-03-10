defmodule Synched.BucketTest do
  use ExUnit.Case, async: true

  test "retrieves values based on the function" do
    {:ok, bucket} = Synched.Bucket.start_link
    assert Synched.Bucket.get(bucket, fn -> "milk" end) == "milk"
  end

  test "it caches the current value" do
    {:ok, bucket} = Synched.Bucket.start_link

    assert Synched.Bucket.get(bucket, fn -> "milk" end) == "milk"
    assert Synched.Bucket.get(bucket, fn -> "not milk" end) == "milk"
  end

  test "it overwrites the value" do
    {:ok, bucket} = Synched.Bucket.start_link

    assert Synched.Bucket.get(bucket, fn -> "milk" end) == "milk"
    assert Synched.Bucket.get(bucket, fn -> "coffee" end) == "milk"
    Synched.Bucket.put(bucket, fn -> "coffee" end)
    assert Synched.Bucket.get(bucket, fn -> "coffee" end) == "coffee"
  end

  test "passes along the state when called with function/1" do
    {:ok, bucket} = Synched.Bucket.start_link
    func = fn x -> if x == :no_value, do: 1, else: x + 1 end

    # reschedule after 10ms
    assert Synched.Bucket.get(bucket, func, 10) == 1
    :timer.sleep(11)
    assert Synched.Bucket.get(bucket, func, 10) == 2
  end

  test "reschedule repeatedly" do
    {:ok, bucket} = Synched.Bucket.start_link
    func = fn x -> if x == :no_value, do: 1, else: x + 1 end

    # reschedule after 10ms
    assert Synched.Bucket.get(bucket, func, 2) == 1
    :timer.sleep(20)
    assert Synched.Bucket.get(bucket, func) > 2
  end
end
