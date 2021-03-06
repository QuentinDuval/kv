defmodule KV.Registry do
  use GenServer


  ## --------------------------------------------------
  ## Client API (Public `functional` API)
  ## ----------------------------<----------------------

  @doc """
  Starts the registry with the given `name`.
  """
  def start_link(name) do
    GenServer.start_link(__MODULE__, :ok, name: name)
  end

  @doc """
  Stops the registry.
  """
  def stop(server) do
    GenServer.stop(server)
  end

  @doc """
  Looks up the bucket pid for `name` stored in `server`.
  Returns `{:ok, pid}` if the bucket exists, `:error` otherwise.
  """
  def lookup(server, name) do
    GenServer.call(server, {:lookup, name})
  end

  @doc """
  Ensures there is a bucket associated to the given `name` in `server`.
  """
  def create(server, name) do
    GenServer.cast(server, {:create, name})
  end


  ## --------------------------------------------------
  ## Server Callbacks (Implementation details)
  ## --------------------------------------------------

  @doc """
  Initialize the server state (returned as 2nd argument)
  """
  def init(:ok) do
    names = %{}
    refs = %{}
    {:ok, {names, refs}}
  end

  @doc """
  Returns a tuple with the new state as 3rd argument
  The reply is the second argument of the tuple
  """
  def handle_call({:lookup, name}, _from, {names, _} = state) do
    {:reply, Map.fetch(names, name), state}
  end

  @doc """
  Requires no answer:
  Returns a tuple with the new state as second element
  """
  def handle_cast({:create, name}, {names, refs} = state) do
    if Map.has_key?(names, name) do
      {:noreply, state}
    else
      {:ok, bucketPid} = KV.Bucket.Supervisor.start_bucket
      ref = Process.monitor(bucketPid)
      refs = Map.put(refs, ref, name)
      names = Map.put(names, name, bucketPid)
      {:noreply, {names, refs}}
    end
  end

  @doc """
  Handles the monitoring information (as well as direct messages)
  Returns the new state as second element.
  """
  def handle_info({:DOWN, ref, :process, _pid, _reason}, {names, refs}) do
    {name, refs} = Map.pop(refs, ref)
    names = Map.delete(names, name)
    {:noreply, {names, refs}}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end

end
