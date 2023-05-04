defmodule PhoenixSVG do
  @moduledoc """
  Inline SVG component for Phoenix. Check out the [README](readme.html) to get started.

  ## Options

    * `:otp_app` - The name of your OTP application. This is required.

    * `:as` - The name of the generated component function. Defaults to `:svg`.

    * `:from` - The path of your svg files relative to your project directory. If using releases,
    make sure this path is included in your release directory (`priv` is included by default).
    Defaults to `priv/svgs`.

    * `:attributes` - A keyword list of default attributes to inject into the SVG tags. Defaults
    to `[]`.

  ## Example

  ```elixir
  use PhoenixSVG,
    otp_app: :myapp,
    as: :icon,
    from: "priv/static/icons",
    attributes: [width: "24px", height: "24px"]
  ```

  ```heex
  <.icon name="checkmark" />
  ```

  """

  import Phoenix.Component
  import Phoenix.HTML

  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      otp_app = Keyword.fetch!(opts, :otp_app)
      as = Keyword.get(opts, :as, :svg)
      from = Keyword.get(opts, :from, "priv/svgs")
      attributes = Keyword.get(opts, :attributes, [])

      svg_path = Application.app_dir(otp_app, from)
      {svgs, hash} = PhoenixSVG.Helpers.list_files(svg_path)

      @phoenix_svg_path svg_path
      @phoenix_svg_hash hash

      for svg <- svgs do
        @external_resource svg

        case PhoenixSVG.Helpers.read_file!(svg, svg_path) do
          {name, [], content} ->
            def unquote(as)(%{name: unquote(name)} = assigns) do
              PhoenixSVG.render(unquote(content), unquote(attributes), assigns)
            end

          {name, path, content} ->
            def unquote(as)(%{name: unquote(name), path: unquote(path)} = assigns) do
              PhoenixSVG.render(unquote(content), unquote(attributes), assigns)
            end
        end
      end

      def unquote(as)(assigns) do
        for_path = if assigns[:path], do: " for path \"#{inspect(assigns.path)}\"", else: ""
        raise "#{inspect(assigns.name)} is not a valid svg#{for_path}"
      end

      def __mix_recompile__? do
        PhoenixSVG.Helpers.list_files(@phoenix_svg_path) |> elem(1) != @phoenix_svg_hash
      end
    end
  end

  @doc false
  def render("<svg" <> tail, attributes, assigns) do
    html_attrs =
      attributes
      |> Enum.into(%{})
      |> Map.merge(assigns)
      |> assigns_to_attributes([:name, :path])
      |> PhoenixSVG.Helpers.to_safe_html_attrs()

    assigns = %{
      inner_content: raw(["<svg ", html_attrs, String.trim(tail)])
    }

    ~H"""
    <%= raw(@inner_content) %>
    """
  end

  @doc """
  Renders an inline SVG using a cached file.

  ## Attributes

    * `:name` - The name of the svg file, excluding the `.svg` extension.

    * `:path` - A list of nested paths if the file is not in the root.

  Any other attributes will be passed through to the SVG tag.
  """
  @callback svg(assigns :: map) :: Phoenix.LiveView.Rendered.t()
end
