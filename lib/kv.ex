defmodule KV do
  use Application

  @doc """
  Describes what should happen when the application starts.
  The link to this module is done via "mix.exs"
  """
  def start(_type, _args) do
    KV.Supervisor.start_link
  end
end
