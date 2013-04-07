defmodule Amnesic.Mixfile do
  use Mix.Project

  def project do
    [ app: :amnesic,
      version: "0.0.1",
      deps: deps ]
  end

  # Configuration for the OTP application
  def application do
    [registered: [:amnesic]]
  end

  # Returns the list of dependencies in the format:
  # { :foobar, "0.1", git: "https://github.com/elixir-lang/foobar.git" }
  defp deps do
    [
      {:couchie, github: "nirvana/couchie"},
      {:con_cache, github: "sasa1977/con_cache"}
    ]
  end
end
