defmodule Servy.PledgeServer do
  # __MODULE__ ensures it is always unique, another option is to do @name :pledge_server
  @name __MODULE__

  # Client Interface

  def start(initial_state \\ []) do
    IO.puts("Starting the pledge server...")
    pid = spawn(__MODULE__, :listen_loop, [initial_state])
    Process.register(pid, @name)
    pid
  end

  def create_pledge(name, amount) do
    # {:ok, id} = send_pledge_to_service(name, amount)
    #
    # # Cache the pledge:
    # [{"larry", 10}]
    send(@name, {self(), :create_pledge, name, amount})

    receive do
      {:response, status} -> status
    end
  end

  def recent_pledges() do
    # Returns the most recent pledges (cache):
    # [{"larry", 10}]
    send(@name, {self(), :recent_pledges})

    receive do
      {:response, pledges} -> pledges
    end
  end

  def total_pledged() do
    send(@name, {self(), :total_pledged})

    receive do
      {:response, total} -> total
    end
  end

  # Server

  def listen_loop(state) do
    # IO.puts("\nWaiting for a message...")

    # Scheduler preempts/suspends blocked process (block on receive) so it doesn't tax CPU
    receive do
      {sender, :create_pledge, name, amount} ->
        {:ok, id} = send_pledge_to_service(name, amount)
        most_recent_pledges = Enum.take(state, 2)
        new_state = [{name, amount} | most_recent_pledges]
        send(sender, {:response, id})
        # IO.puts("#{name} pledged #{amount}!")
        # IO.puts("New state is #{inspect(new_state)}")
        listen_loop(new_state)

      {sender, :recent_pledges} ->
        # sender is Client process pid
        send(sender, {:response, state})
        # IO.puts("Sent pledges to #{inspect(sender)}")
        listen_loop(state)

      {sender, :total_pledged} ->
        # "elem" takes a tuple and gives you the value of an index. In this case, 0 for name, 1 for amount.
        total = Enum.map(state, &elem(&1, 1)) |> Enum.sum()
        send(sender, {:response, total})
        listen_loop(state)

      unexpected ->
        IO.puts("Unexpected message: #{inspect(unexpected)}")
        listen_loop(state)
    end
  end

  defp send_pledge_to_service(_name, _amount) do
    # CODE GOES HERE TO SEND PLEDGE TO EXTERNAL SERVICE
    {:ok, "pledge-#{:rand.uniform(1000)}"}
  end
end

# # Client process code
# alias Servy.PledgeServer
#
# # Server process is listen loop
# pid = PledgeServer.start()
#
# send(pid, {:stop, "hammertime"})
#
# IO.inspect(PledgeServer.create_pledge("larry", 10))
# IO.inspect(PledgeServer.create_pledge("moe", 20))
# IO.inspect(PledgeServer.create_pledge("curly", 30))
# IO.inspect(PledgeServer.create_pledge("daisy", 40))
# IO.inspect(PledgeServer.create_pledge("grace", 50))
#
# IO.inspect(PledgeServer.recent_pledges())
#
# IO.inspect(PledgeServer.total_pledged())
#
# IO.inspect(Process.info(pid, :messages))
