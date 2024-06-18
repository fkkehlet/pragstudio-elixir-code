defmodule Servy.FourOhFourSupervisor do
  use Supervisor

  def start_link(_arg) do
    IO.puts("Starting the 404 counter supervisor...")
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__ )
  end

  def init(:ok) do
    children = [Servy.FourOhFourCounter]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
