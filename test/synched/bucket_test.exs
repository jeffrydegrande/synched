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
end
