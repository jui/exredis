defmodule Exredis.Pool do
  use Supervisor

  def start_link do
    :supervisor.start_link(__MODULE__, [])
  end

  def init([]) do
    # Here are my pool options
    pool_options = [
                     name: {:local, :exredis_pool},
                     worker_module: :eredis,
                     size: 10,
                     max_overflow: 100
                 ]
    children = [
                 :poolboy.child_spec(:exredis_pool, pool_options, ["localhost",6379,0,"",:no_reconnect])
             ]
    supervise(children, strategy: :one_for_one)
  end

  @doc """
  Make query

  * `query(client, ["SET", "foo", "bar"])`
  * `query(client, ["GET", "foo"])`
  * `query(client, ["MSET" | ["k1", "v1", "k2", "v2", "k3", "v3"]])`
  * `query(client, ["MGET" | ["k1", "k2", "k3"]])`

  See more commands in official Redis documentation
  """
  @spec query(list) :: any
  def query(command) when is_list(command), do:
    client = :poolboy.checkout(:exredis_pool)
    ret = client |> :eredis.q(command) |> elem 1
    :poolboy.checkin(:exredis_pool, client)
    ret

  @doc """
  Pipeline query

  ```
  query_pipe(client, [["SET", :a, "1"],
                      ["LPUSH", :b, "3"],
                      ["LPUSH", :b, "2"]])
  ```
  """
  @spec query_pipe(list) :: any
  def query_pipe(command) when is_list(command), do:
    client = :poolboy.checkout(:exredis_pool)
    ret = client |> :eredis.qp command
   :poolboy.checkin(:exredis_pool, client)
   ret
    
end

