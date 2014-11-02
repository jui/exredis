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
	
    
end

