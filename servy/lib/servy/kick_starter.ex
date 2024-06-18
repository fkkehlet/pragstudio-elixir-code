defmodule Servy.KickStarter do
  use GenServer
  @name __MODULE__

  def start_link(_arg) do
    IO.puts("Starting the kickstarter...")
    GenServer.start_link(@name, :ok, name: @name)
  end

  def init(:ok) do
    Process.flag(:trap_exit, true)
    server_pid = start_server()
    # The state we initialize with in this case is the server pid
    {:ok, server_pid}
  end

  # Client Interface

  def get_server() do
    GenServer.call(@name, :get_server)
  end

  # Server Callbacks

  def handle_call(:get_server, _from, server_pid) do
    {:reply, server_pid, server_pid}

  end

  def handle_info({:EXIT, _pid, reason}, _state) do
    IO.puts("HttpServer exited (#{inspect(reason)})")
    server_pid = start_server()
    {:noreply, server_pid}
  end

  defp start_server() do

    IO.puts("Starting the HTTP server...")
    server_pid = spawn_link(Servy.HttpServer, :start, [4000])
    # Process.link(server_pid) not needed due to using spawn_link
    Process.register(server_pid, :http_server)
    server_pid
  end
end
