defmodule Servy.FourOhFourCounter do
  @name __MODULE__

  def start() do
    pid = spawn(__MODULE__, :listen_loop, [%{}])
    Process.register(pid, @name)
    pid
  end

  def bump_count(route) do
    send(@name, {self(), :bump_count, route})

    receive do
      {:response, status} -> status
    end
  end

  def get_count(route) do
    send(@name, {self(), :get_count, route})

    receive do
      {:response, count} -> count
    end
  end

  def get_counts() do
    send(@name, {self(), :get_counts})

    receive do
      {:response, counts} -> counts
    end

  end

  def listen_loop(state) do
    receive do
      {sender, :bump_count, route} ->
        new_state = Map.update(state, route, 1, fn(current_count) -> current_count + 1 end)
        send(sender, {:response, {:ok, "Bumped!"}})
        listen_loop(new_state)

      {sender, :get_count, route} ->
        count = Map.get(state, route, "Route has not been hit!")
        send(sender, {:response, count})
        listen_loop(state)

      {sender, :get_counts} ->
        send(sender, {:response, state})
        listen_loop(state)

      unexpected ->
        IO.puts("Unexpected message: #{inspect(unexpected)}")
        listen_loop(state)
    end

  end
end
