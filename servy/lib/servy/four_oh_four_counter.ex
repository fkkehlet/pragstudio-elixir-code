# defmodule Servy.FourOhGenServer do
#   def start(callback_module, initial_state, name) do
#     pid = spawn(__MODULE__, :listen_loop, [initial_state, callback_module])
#     Process.register(pid, name)
#     pid
#   end
#
#   def call(pid, message) do
#     send(pid, {:call, self(), message})
#     receive do {:response, response} -> response end
#   end
#
#   def cast(pid, message) do
#     send(pid, {:cast, message})
#   end
#
#   def listen_loop(state, callback_module) do
#     receive do
#       {:call, sender, message} when is_pid(sender) ->
#         {response, new_state} = callback_module.handle_call(message, state)
#         send(sender, {:response, response})
#         listen_loop(new_state, callback_module)
#       {:cast, message} ->
#         new_state = callback_module.handle_cast(message, state)
#         listen_loop(new_state, callback_module)
#       unexpected ->
#         IO.puts("Unexpected message: #{inspect(unexpected)}")
#         listen_loop(state, callback_module)
#     end
#   end
# end

defmodule Servy.FourOhFourCounter do
  @name __MODULE__

  use GenServer

  # alias Servy.FourOhGenServer, as: FourOhGenServer

  def start() do
   GenServer.start(__MODULE__, %{}, name: @name)
  end

  def bump_count(route) do
    GenServer.call(@name, {:bump_count, route})
  end

  def get_count(route) do
    GenServer.call(@name, {:get_count, route})
  end

  def get_counts() do
    GenServer.call(@name, :get_counts)
  end

  def reset() do
    GenServer.cast(@name, :reset)
  end

  def init(init_arg) do
    {:ok, init_arg}
  end

  def handle_call({:bump_count, route}, _from, state) do
    new_state = Map.update(state, route, 1, fn(current_count) -> current_count + 1 end)
    {:reply, :ok, new_state}
  end

  def handle_call({:get_count, route}, _from, state) do
    count = Map.get(state, route, "Route has not been hit!")
    {:reply, count, state}
  end

  def handle_call(:get_counts, _from, state) do
    {:reply, state, state}
  end

  def handle_cast(:reset, _state) do
    {:noreply, %{}}
  end

  # def listen_loop(state) do
  #   receive do
  #     {sender, :bump_count, route} ->
  #       new_state = Map.update(state, route, 1, fn(current_count) -> current_count + 1 end)
  #       send(sender, {:response, {:ok, "Bumped!"}})
  #       listen_loop(new_state)
  #
  #     {sender, :get_count, route} ->
  #       count = Map.get(state, route, "Route has not been hit!")
  #       send(sender, {:response, count})
  #       listen_loop(state)
  #
  #     {sender, :get_counts} ->
  #       send(sender, {:response, state})
  #       listen_loop(state)
  #
  #     unexpected ->
  #       IO.puts("Unexpected message: #{inspect(unexpected)}")
  #       listen_loop(state)
  #   end
  #
  # end
end

# alias Servy.FourOhFourCounter
#
# pid = FourOhFourCounter.start()
#
# send(pid, {:stop, "hammertime"})
#
# IO.inspect(FourOhFourCounter.bump_count("/larry"))
# IO.inspect(FourOhFourCounter.bump_count("/moe"))
# IO.inspect(FourOhFourCounter.bump_count("/curly"))
# IO.inspect(FourOhFourCounter.bump_count("/larry"))
# IO.inspect(FourOhFourCounter.get_count("/larry"))
# IO.inspect(FourOhFourCounter.get_count("/grace"))
# IO.inspect(FourOhFourCounter.get_counts())
# IO.inspect(Process.info(pid, :messages))
