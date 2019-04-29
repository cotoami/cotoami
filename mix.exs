defmodule Cotoami.Mixfile do
  use Mix.Project

  def project do
    [
      app: :cotoami,
      version: "0.23.0-dev+#{build_timestamp()}",
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  defp build_timestamp do
    {{year, month, day}, {_hour, _minute, _}} = :calendar.local_time()

    :io_lib.format("~4..0B~2..0B~2..0B", [year, month, day])
    |> List.flatten()
    |> to_string
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Cotoami.Application, []},
      extra_applications: [:logger, :runtime_tools, :poison]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:dialyxir, "~> 0.5", only: [:dev], runtime: false},
      {:credo, "~> 0.8", only: [:dev, :test], runtime: false},
      {:phoenix, "~> 1.3.2"},
      {:phoenix_pubsub, "~> 1.0"},
      {:phoenix_ecto, "~> 3.2"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 2.10"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:gettext, "~> 0.11"},
      {:cowboy, "~> 1.0"},
      {:redix, "~> 0.4"},
      {:bamboo, "~> 0.8"},
      {:bamboo_smtp, "~> 1.4.0"},
      {:httpotion, "~> 3.0.2"},
      {:bolt_sips, "~> 0.3"},
      {:uuid, "~> 1.1"},
      {:shorter_maps, "~> 2.2"},
      {:logster, "~> 0.6"},
      {:oauth2, "~> 0.9"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
