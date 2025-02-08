defmodule PhoenixSVG.MixProject do
  use Mix.Project

  @url "https://github.com/jsonmaur/phoenix-svg"

  def project do
    [
      app: :phoenix_svg,
      version: "1.1.0",
      elixir: "~> 1.13",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      source_url: @url,
      homepage_url: "#{@url}#readme",
      description: "Inline SVG component for Phoenix",
      package: [
        licenses: ["MIT"],
        links: %{"GitHub" => @url},
        files: ~w(lib .formatter.exs CHANGELOG.md LICENSE mix.exs README.md)
      ],
      docs: [
        main: "readme",
        extras: ["README.md"],
        authors: ["Jason Maurer"]
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
      {:ex_doc, "~> 0.37", only: :dev, runtime: false},
      {:makeup_eex, "~> 2.0", only: :dev},
      {:phoenix_live_view, "~> 1.0"}
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
