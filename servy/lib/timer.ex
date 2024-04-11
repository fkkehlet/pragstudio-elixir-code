defmodule Timer do
  def remind(reminder, seconds) do
    spawn(fn() ->
      :timer.sleep(seconds * 1000)
      IO.puts(reminder)
    end)
  end
end

# Timer.remind("Stand Up", 1)
# Timer.remind("Sit Down", 2)
# Timer.remind("Fight, Fight, Fight", 3)

# Elixir can create processes REALLY fast!
# Enum.map(1..10_000, fn(x) -> spawn(fn -> IO.puts x * x end) end)
# for x <- 1..10_000, do: spawn(fn -> IO.puts x * x end)
