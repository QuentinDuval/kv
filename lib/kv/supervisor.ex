defmodule KV.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    # Each worker will monitor a registry
    # It will spawn this one via KV.Registry.start_link(KV.Registry)
    children = [
      worker(KV.Registry, [KV.Registry]),
      supervisor(KV.Bucket.Supervisor, [])
    ]
    # Check: http://elixir-lang.org/getting-started/mix-otp/supervisor-and-application.html
    supervise(children, strategy: :rest_for_one)
  end
end
