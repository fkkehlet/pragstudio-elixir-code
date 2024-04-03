defmodule ServyTest do
  use ExUnit.Case
  doctest Servy

  # test "greets the world" do
  #   assert Servy.hello() == :world
  # end

  test "the truth" do
    assert 1 + 1 === 2
    refute 2 + 1 === 2
  end
end
