defmodule Synched.RegistryTest do
  use ExUnit.Case, async: true

  setup context do
    {:ok, registry} = Synched.Registry.start_link(context.test)
    {:ok, registry: registry}
  end

  test "spawns a bucket", %{registry: registry} do
    assert Synched.Registry.lookup(registry, "shopping") == :error

    Synched.Registry.create(registry, "shopping")
    assert {:ok, bucket} = Synched.Registry.lookup(registry, "shopping")

    assert Synched.Bucket.get(bucket, fn -> 1 end) == 1
  end

  test "removes buckets on exit", %{registry: registry} do
    Synched.Registry.create(registry, "shopping")

    {:ok, bucket} = Synched.Registry.lookup(registry, "shopping")
    Agent.stop(bucket)
    assert Synched.Registry.lookup(registry, "shopping") == :error
  end

  test "removes bucket on crash", %{registry: registry} do
    Synched.Registry.create(registry, "shopping")
    {:ok, bucket} = Synched.Registry.lookup(registry, "shopping")

    # Stop the bucket with non-normal reason
    Process.exit(bucket, :shutdown)

    # Wait until the bucket is dead
    ref = Process.monitor(bucket)
    assert_receive {:DOWN, ^ref, _, _, _}

    assert Synched.Registry.lookup(registry, "shopping") == :error
  end
end
