defmodule Servy do
  # def hello(name) do
  #   "Hello #{name}"
  # end

  # Application behavior expects callback module to define a start function
  use Application

  def start(_type, _args) do
    IO.puts("Starting the application...")
    {:ok, _sup_pid} = Servy.Supervisor.start_link()
  end
end

# IO.puts(Servy.hello("Elixir"))
