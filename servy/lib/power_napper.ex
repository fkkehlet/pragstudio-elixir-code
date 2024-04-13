defmodule PowerNapper do
  def nap() do
    power_nap = fn() ->
      time = :rand.uniform(10_000)
      :timer.sleep(time)
      time
    end

    caller = self()

    spawn(fn -> send(caller, {:slept, power_nap.()}) end)

    receive do
      {:slept, time} -> IO.puts("Slept for #{time} ms!")
    end
  end
end
