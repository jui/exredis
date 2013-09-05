Code.require_file "test_helper.exs", __DIR__

defmodule ApiMixin do
  use Exredis.Api

  def set(client), do:
    client |> set "key", "value"

  def get(client), do:
    client |> get "key"

end

defmodule ApiTest do
  use ExUnit.Case, sync: true
  alias Exredis, as: E
  alias Exredis.Api, as: R

  setup do
    client = E.start

    # clean up database and set test value
    client |> E.query ["FLUSHALL"]
    client |> E.query ["SET", "key", "value"]

    { :ok, [c: client] }
  end

  teardown ctx, do:
    ctx[:c] |> E.stop


  test "mixin", c do
    assert (c[:c] |> ApiMixin.set) == "OK"
    assert (c[:c] |> ApiMixin.get) == "value"
  end

  ##
  # Keys
  ##

  test "del", c do
    assert (c[:c] |> R.del "key") == "1"
    assert (c[:c] |> R.get "key") == :undefined
  end

  test "keys", c do
    c[:c] |> R.flushall
    c[:c] |> R.mset ["k1", "v1", "k2", "v2"]

    assert (c[:c] |> R.keys "k*") == ["k1", "k2"]
  end

  ##
  # Strigns
  ##

  test "get", c do
    assert (c[:c] |> R.get "key") == "value"
  end

  test "set", c do
    assert (c[:c] |> R.set "key-2", "value-2") == "OK"
    assert (c[:c] |> R.get "key-2") == "value-2"
  end

  test "mset", c do
    assert (c[:c] |> R.mset ["k1", "v1", "k2", "v2"]) == "OK"
    assert (c[:c] |> R.get "k1") == "v1"
    assert (c[:c] |> R.get "k2") == "v2"
  end

  test "mget", c do
    assert (c[:c] |> R.mset ["k1", "v1", "k2", "v2"]) == "OK"
    assert (c[:c] |> R.mget ["k1", "k2"]) == ["v1", "v2"]
  end

  ##
  # Pub/Sub
  ##

  test "publish", c do
    assert (c[:c] |> R.publish "ch", "msg") == "0"
  end

  ##
  # Server
  ##

  test "flushall", c do
    assert (c[:c] |> R.flushall) == "OK"
    assert (c[:c] |> R.get "key") == :undefined
  end

end