defmodule KV.BucketTest do
  use ExUnit.Case, async: true

  @doc """
  Setup for all the tests: create a link for the bucket.
  """
  setup do
    {:ok, bucket} = KV.Bucket.start_link
    {:ok, bucket: bucket}
  end

  @doc """
  A unit test to check that inserting an element works fine
  Capture the bucket of the setup using the map as snd param
  """
  test "stores values by key", %{bucket: bucket} do
    assert KV.Bucket.get(bucket, "milk") == nil
    KV.Bucket.put(bucket, "milk", 3)
    assert KV.Bucket.get(bucket, "milk") == 3
    assert KV.Bucket.delete(bucket, "milk") == 3
    assert KV.Bucket.get(bucket, "milk") == nil
  end
end
