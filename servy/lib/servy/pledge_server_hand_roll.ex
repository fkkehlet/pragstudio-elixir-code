defmodule Servy.GenericServer do
  def start(callback_module, initial_state, name) do
    pid = spawn(__MODULE__, :listen_loop, [initial_state, callback_module])
    Process.register(pid, name)
    pid
  end

  # RPC, synchonous process which sends message to server and waits for a response
  def call(pid, message) do
    send(pid, {:call, self(), message})
    receive do {:response, response} -> response end
  end

  def cast(pid, message) do
    send(pid, {:cast, message})
  end

  def listen_loop(state, callback_module) do
    receive do
      {:call, sender, message} when is_pid(sender) ->
        {response, new_state} = callback_module.handle_call(message, state)
        send(sender, {:response, response})
        listen_loop(new_state, callback_module)
      {:cast, message} ->
        new_state = callback_module.handle_cast(message, state)
        listen_loop(new_state, callback_module)
      unexpected_message ->
        new_state = callback_module.handle_info(unexpected_message, state)
        listen_loop(new_state, callback_module)
    end
  end
end

defmodule Servy.PledgeServerHandRoll do
  # __MODULE__ ensures it is always unique, another option is to do @name :pledge_server
  @name __MODULE__

  alias Servy.GenericServer

  # Client Interface

  def start() do
    IO.puts("Starting the pledge server...")
    GenericServer.start(__MODULE__, [], @name)
  end

  def create_pledge(name, amount) do GenericServer.call(@name, {:create_pledge, name, amount}) end

  def recent_pledges() do GenericServer.call(@name, :recent_pledges) end

  def total_pledged() do GenericServer.call(@name, :total_pledged) end

  def clear() do GenericServer.cast(@name, :clear) end

  # Server callbacks

  def handle_call(:total_pledged, state) do
    total = Enum.map(state, &elem(&1, 1)) |> Enum.sum()
    {total, state}
  end

  def handle_call(:recent_pledges, state) do
    {state, state}
  end

  def handle_call({:create_pledge, name, amount}, state) do
    {:ok, id} = send_pledge_to_service(name, amount)
    most_recent_pledges = Enum.take(state, 2)
    new_state = [{name, amount} | most_recent_pledges]
    {id, new_state}
  end

  def handle_cast(:clear, _state) do
    []
  end

  def handle_info(msg, state) do
    IO.puts("Unexpected message: #{inspect(msg)}")
    state
  end

  defp send_pledge_to_service(_name, _amount) do
    # CODE GOES HERE TO SEND PLEDGE TO EXTERNAL SERVICE
    {:ok, "pledge-#{:rand.uniform(1000)}"}
  end
end

# # Client process code
# alias Servy.PledgeServerHandRoll, as: GenServer

# Server process is listen loop
# pid = GenServer.start()
#
# send(pid, {:stop, "hammertime"})
#
# IO.inspect(GenServer.create_pledge("larry", 10))
# IO.inspect(GenServer.create_pledge("moe", 20))
# IO.inspect(GenServer.create_pledge("curly", 30))
# IO.inspect(GenServer.create_pledge("daisy", 40))
# IO.inspect(GenServer.create_pledge("grace", 50))
#
# IO.inspect(GenServer.recent_pledges())
#
# IO.inspect(GenServer.total_pledged())
#
# IO.inspect(Process.info(pid, :messages))
