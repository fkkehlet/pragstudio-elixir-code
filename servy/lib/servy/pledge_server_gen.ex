defmodule Servy.PledgeServerGen do
  # __MODULE__ ensures it is always unique, another option is to do @name :pledge_server
  @name __MODULE__

  # Injects default implementations, so we don't have to define other
  # This module is a server process which at a fundamental level behaves like all other GenServer processes
  use GenServer

  defmodule State do
    defstruct cache_size: 3, pledges: []
  end

  def child_spec(_arg) do
    %{id: Servy.PledgeServerGen, restart: :temporary, shutdown: 5000,
      start: {Servy.PledgeServerGen, :start_link, [[]]}, type: :worker}
  end

  # Client Interface
  def start_link(_arg) do
    IO.puts("Starting the pledge server...")
    GenServer.start_link(__MODULE__, %State{}, name: @name)
  end

  def set_cache_size(size) do
    GenServer.cast(@name, {:set_cache_size, size})
  end

  def create_pledge(name, amount) do GenServer.call(@name, {:create_pledge, name, amount}) end

  def recent_pledges() do GenServer.call(@name, :recent_pledges) end

  def total_pledged() do GenServer.call(@name, :total_pledged, 5000) end

  def clear() do GenServer.cast(@name, :clear) end

  # Server callbacks

  # init is automatically called, and "args" is populated in this casy by %State{}
  # start will block until init function returns
  def init(args) do
    state = args
    pledges = fetch_recent_pledges_from_service()
    new_state = %{state | pledges: pledges}
    {:ok, new_state}
  end

  # Handles unexpected messages, e.g., send()
  def handle_info(msg, state) do
    IO.puts("Can't touch this! #{inspect(msg)}")
    {:noreply, state}
  end

  def handle_call(:total_pledged, _from, state) do
    total = Enum.map(state.pledges, &elem(&1, 1)) |> Enum.sum()
    {:reply, total, state}
  end

  def handle_call(:recent_pledges, _from, state) do
    {:reply, state.pledges, state}
  end

  def handle_call({:create_pledge, name, amount}, _from, state) do
    {:ok, id} = send_pledge_to_service(name, amount)
    # minus 1 because we are going to add newest pledge to the head of the list
    most_recent_pledges = Enum.take(state.pledges, state.cache_size - 1)
    cached_pledges = [{name, amount} | most_recent_pledges]
    new_state = %{state | pledges: cached_pledges}
    {:reply, id, new_state}
  end

  def handle_cast(:clear, state) do
    # Returns new struct with current cache size but the pledges field is changed to an empty list
    {:noreply, %{ state | pledges: []}}
  end

  def handle_cast({:set_cache_size, size}, state) do
    resized_cache = Enum.take(state.pledges, size)
    new_state = %{state | cache_size: size, pledges: resized_cache}
    {:noreply, new_state}
  end

  defp send_pledge_to_service(_name, _amount) do
    # CODE GOES HERE TO SEND PLEDGE TO EXTERNAL SERVICE
    {:ok, "pledge-#{:rand.uniform(1000)}"}
  end

  defp fetch_recent_pledges_from_service() do
    # CODE GOES HERE TO FETCH RECENT PLEDGES FROM EXTERNAL SERVICE

    # Example return value
    [{"wilma", 15}, {"fred", 25}]
  end
end

# alias Servy.PledgeServerGen
#
# {:ok, pid} = PledgeServerGen.start()
#
# send(pid, {:stop, "hammertime"})
#
# PledgeServerGen.set_cache_size(4)
#
# IO.inspect(PledgeServerGen.create_pledge("larry", 10))
# # IO.inspect(PledgeServerGen.create_pledge("moe", 20))
# # IO.inspect(PledgeServerGen.create_pledge("curly", 30))
# # PledgeServerGen.clear()
# # IO.inspect(PledgeServerGen.create_pledge("daisy", 40))
# # IO.inspect(PledgeServerGen.create_pledge("grace", 50))
#
#
# IO.inspect(PledgeServerGen.recent_pledges())
# IO.inspect(PledgeServerGen.total_pledged())
# IO.inspect(Process.info(pid, :messages))
