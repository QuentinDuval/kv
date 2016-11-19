defmodule KV.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    children = [
      worker(KV.Registry, [KV.Registry]),
      supervisor(KV.Bucket.Supervisor, [])
    ]
    # The :rest_for_one allows to kill the buckets if the registry crashes
    # The order is quite important:
    # - children are spawned from first to last
    # - children are restarted and crashes from first to last
    # It is especially important if there are dependencies between the children
    supervise(children, strategy: :rest_for_one)
  end
end
