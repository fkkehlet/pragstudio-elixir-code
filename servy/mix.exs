defmodule Servy.MixProject do
  use Mix.Project

  def project do
    [
      app: :servy,
      description: "A humble HTTP server",
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :eex, :observer, :wx, :runtime_tools],
      # Specifies the callback module to invoke when the application is started, and passes args
      mod: {Servy, []}, # OR Servy.Application
      env: [port: 3000]
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


# elixir --erl "-servy port 5000" -S mix run --no-halt

# Use mix new <app> --sup to generate an application callback with a supervisor!
