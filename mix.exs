defmodule PhoenixIcon.MixProject do
  use Mix.Project

  @url "https://github.com/jsonmaur/phoenix-icon"

  def project do
    [
      app: :phoenix_icon,
      version: "1.0.1",
      elixir: "~> 1.13",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      source_url: @url,
      homepage_url: "#{@url}#readme",
      description: "Use SVG icons in Phoenix",
      authors: ["Jason Maurer"],
      package: [
        licenses: ["MIT"],
        links: %{"GitHub" => @url},
        files: [
          "lib",
          ".formatter.exs",
          "CHANGELOG.md",
          "LICENSE",
          "mix.exs",
          "README.md"
        ]
      ],
      docs: [
        main: "readme",
        extras: ["README.md"]
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.27", only: :dev, runtime: false},
      {:makeup_eex, "~> 0.1", only: :dev, runtime: false},
      {:phoenix_live_view, "~> 0.17"}
    ]
  end

  defp aliases do
    [
      test: [
        "format --check-formatted",
        "deps.unlock --check-unused",
        "compile --warnings-as-errors",
        "test"
      ]
    ]
  end
end
