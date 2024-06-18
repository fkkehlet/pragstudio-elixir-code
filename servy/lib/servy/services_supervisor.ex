defmodule Servy.ServicesSupervisor do
  # A supervisor is a process
  use Supervisor

  def start_link(_arg) do
    IO.puts("Starting the services supervisor...")
    # Spawns a supervisor process and links it to the calling process
    # Takes a callback module, expected to implement init
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  # Callback which tells supervisor which children to start and supervise
  def init(:ok) do
    children = [
      Servy.PledgeServerGen,
      {Servy.SensorServer, [interval: :timer.minutes(5), target: "bigfoot"]}

      # {Servy.SensorServer, :frequent} # Matches to child_spec function clause

      # For more fine-grained control, you can also specify the child as a map
      # containing at least the :id and :start fields of the child specification
      # %{
      #     id: Servy.SensorServer,
      #     start: {Servy.SensorServer, :start_link, [60]}
      #   }
    ]

    # An example of setting all the supervisor options, overriding the defaults
    opts = [strategy: :one_for_one, max_restarts: 5, max_seconds: 10]
    Supervisor.init(children, opts)
  end
end
