defmodule SlurpieTest do
  use ExUnit.Case
  doctest Slurpie

  test "greets the world" do
    assert Slurpie.hello() == :world
  end
end
