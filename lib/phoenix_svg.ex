defmodule PhoenixSVG do
  @moduledoc """
  Use inline SVGs in Phoenix
  """

  import Phoenix.Component

  defmacro __using__(opts) do
    otp_app = Keyword.fetch!(opts, :otp_app)
    as = Keyword.get(opts, :as, :svg)
    base_path = Keyword.get(opts, :path, "priv/svgs")
    attributes = Keyword.get(opts, :attributes, %{})

    svgs_path = Application.app_dir(otp_app, base_path)
    {svgs, hash} = PhoenixSVG.list_files(svgs_path)

    [
      for svg <- svgs do
        {name, path, data} = PhoenixSVG.read_file!(svg, svgs_path)
        pattern_match = if path == [], do: %{name: name}, else: %{name: name, path: path}

        quote do
          @external_resource unquote(svg)

          def unquote(as)(unquote(Macro.escape(pattern_match)) = assigns) do
            html_attrs =
              unquote(Macro.escape(attributes))
              |> Map.merge(assigns)
              |> Phoenix.Component.assigns_to_attributes([:name, :path])
              |> PhoenixSVG.to_safe_html_attrs()

            "<svg" <> tail = unquote(data)

            PhoenixSVG.svg(%{
              inner_content: Phoenix.HTML.raw(["<svg ", html_attrs, String.trim(tail)])
            })
          end
        end
      end,
      quote do
        def unquote(as)(assigns) do
          for_path = if assigns[:path], do: " for path \"#{inspect(assigns.path)}\"", else: ""
          raise "#{inspect(assigns.name)} is not a valid svg#{for_path}"
        end

        def __mix_recompile__? do
          unquote(hash) != PhoenixSVG.list_files(unquote(svgs_path)) |> elem(1)
        end
      end
    ]
  end

  @doc """
  Renders an inline svg from a cached file.

  ## Attributes

    * `:name` - The name of the svg file, excluding the `.svg` extension.
    * `:path` - A list of nested paths if the file is not in the root.

  Any other attributes will be passed through to the `<svg>` tag.

  Note that this function should never be called directly with `PhoenixSVG.svg`. It's meant to
  be called from the `svg` function generated in the `__using__` macro. See the [Getting Started](readme.html#getting-started)
  guide.
  """
  def svg(assigns) do
    ~H"""
    <%= Phoenix.HTML.raw(@inner_content) %>
    """
  end

  @doc """
  List all of the SVG files in the given directory.

  Returns a list of all the files, and an MD5 hash of the list so it can be determined if the list
  changed and needs to be re-compiled.
  """
  def list_files(path) do
    files =
      path
      |> Path.join("**/*.svg")
      |> Path.wildcard()

    {files, :erlang.md5(files)}
  end

  @doc """
  Reads a file and parses out the name and path.

  The name will be the filename without the extension, and the path will be a list of directory
  names the file is nested in relative to the base path.
  """
  def read_file!(filepath, base_path) do
    data = File.read!(filepath) |> String.trim()
    name = Path.basename(filepath) |> Path.rootname()
    rel_path = Path.relative_to(filepath, base_path)

    path =
      rel_path
      |> Path.dirname()
      |> Path.split()
      |> Enum.reject(&(&1 == "."))

    {name, path, data}
  end

  @doc """
  Converts a map or keyword list into HTML-safe attributes.

  Any keys that contain an underscore will be converted to a dash in the HTMl attribute. For
  example, `%{foo_bar: "foo_bar"}` will result in the attribute `foo-bar="foo_bar"`.
  """
  def to_safe_html_attrs(data) do
    for {key, value} <- data do
      key =
        key
        |> Atom.to_string()
        |> String.replace("_", "-")
        |> Phoenix.HTML.Safe.to_iodata()

      [key, ?=, ?", Phoenix.HTML.Safe.to_iodata(value), ?", ?\s]
    end
  end
end
