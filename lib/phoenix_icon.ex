defmodule PhoenixIcon do
  @moduledoc """
  Use SVG icons in Phoenix
  """

  import Phoenix.Component

  @base_path Application.compile_env(:phoenix_icon, :base_path, "priv/icons")
  @attributes Application.compile_env(:phoenix_icon, :attributes, %{})

  defmacro __using__(opts) do
    otp_app = Keyword.fetch!(opts, :otp_app)
    icons_path = Application.app_dir(otp_app, @base_path)
    {icons, hash} = PhoenixIcon.list_svgs(icons_path)

    [
      for icon <- icons do
        {name, type, data} = PhoenixIcon.read_icon!(icon, icons_path)
        pattern_match = if type == [], do: %{name: name}, else: %{name: name, type: type}

        quote do
          @external_resource unquote(icon)

          def icon(unquote(Macro.escape(pattern_match)) = assigns) do
            html_attrs =
              unquote(Macro.escape(@attributes))
              |> Map.merge(assigns)
              |> Phoenix.Component.assigns_to_attributes([:name, :type])
              |> PhoenixIcon.to_safe_html_attrs()

            "<svg" <> tail = unquote(data)

            PhoenixIcon.icon(%{
              inner_content: Phoenix.HTML.raw(["<svg ", html_attrs, String.trim(tail)])
            })
          end
        end
      end,
      quote do
        @icons_path unquote(icons_path)

        def icon(assigns) do
          for_type = if assigns[:type], do: " for type \"#{inspect(assigns.type)}\"", else: ""
          raise "#{inspect(assigns.name)} is not a valid icon#{for_type}"
        end

        def __mix_recompile__? do
          unquote(hash) != PhoenixIcon.list_svgs(@icons_path) |> elem(1)
        end
      end
    ]
  end

  @doc """
  Renders an icon from a cached SVG file.

  ## Attributes

    * `:name` - The name of the icon, excluding the `.svg` extension.
    * `:type` - A list of nested directories if the icon is not in the root.

  Any other attributes will be passed through to the `<svg>` tag.

  Note that this function should never be called directly with `PhoenixIcon.icon`. It's meant to
  be called from the `icon` function generated in the `__using__` macro. See the [Getting Started](readme.html#getting-started)
  guide.
  """
  def icon(assigns) do
    ~H"""
    <%= Phoenix.HTML.raw(@inner_content) %>
    """
  end

  @doc """
  List all of the SVG files in the given directory.

  Returns a list of all the files, and an MD5 hash of the list so it can be determined if the list
  changed and needs to be re-compiled.
  """
  def list_svgs(path) do
    files =
      path
      |> Path.join("**/*.svg")
      |> Path.wildcard()

    {files, :erlang.md5(files)}
  end

  @doc """
  Reads an icon file contents and parses out the name and type.

  The icon name will be the filename without the extension, and the type will be a list of each
  directory the file is nested in relative to the base icon path.
  """
  def read_icon!(path, base_path) do
    data = File.read!(path) |> String.trim()
    name = Path.basename(path) |> Path.rootname()
    rel_path = Path.relative_to(path, base_path)

    type =
      rel_path
      |> Path.dirname()
      |> Path.split()
      |> Enum.reject(&(&1 == "."))

    {name, type, data}
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
