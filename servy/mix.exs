defmodule Servy.MixProject do
  use Mix.Project

  def project do
    [
      app: :servy,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :eex, :observer, :wx, :runtime_tools]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:earmark, "~> 1.4"},
      {:faker, "~> 0.18.0"},
      {:httpoison, "~> 2.2"},
      {:poison, "~> 5.0"}
    ]
  end
end
