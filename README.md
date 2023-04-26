<a href="https://github.com/jsonmaur/phoenix-icon/actions/workflows/test.yml"><img alt="Test Status" src="https://img.shields.io/github/actions/workflow/status/jsonmaur/phoenix-icon/test.yml?label=&style=for-the-badge&logo=github"></a> <a href="https://hexdocs.pm/phoenix_icon/"><img alt="Hex Version" src="https://img.shields.io/hexpm/v/phoenix_icon?style=for-the-badge&label=&logo=elixir" /></a>

Use a folder of SVGs for icons in your Phoenix applications. This library will load the files during compilation so you don't have to worry about performance, inline the SVG tags into your templates, and includes support for defining custom attributes with defaults.

## Getting Started

```elixir
def deps do
  [
    {:phoenix_icon, "~> 1.0"}
  ]
end
```

In `lib/myapp_web.ex`, add `use PhoenixIcon` to the top of `html_helpers` (replacing `myapp` with the name of your app):

```elixir
defp html_helpers do
  quote do
    use PhoenixIcon, otp_app: :myapp

    # If you're using the Core components that come with a new Phoenix installation,
    # exclude the `icon` component to avoid a function naming conflict.
    import MyAppWeb.CoreComponents, except: [icon: 1]
```

Now when you start your Phoenix server, all the SVG files located in `priv/icons` will be loaded into memory and can be used with the icon component. Any attributes defined will be passed through to the `<svg>` tag. For example, if you have an icon at `priv/icons/account.svg`:

```heex
<.icon name="account" class="foobar" />
```

An error will be raised if the icon is not found. If your icons are nested in a subdirectory, specify a list in the `type` attribute with one item representing each folder. e.g. for `priv/icons/generic/account.svg`:

```heex
<.icon name="account" type={["generic"]} class="foobar" />
```

## Configuration

You can customize the following config items:

* `:base_path` The path of your icons relative to your project directory. If using releases, make sure this path is included in your release directory (`priv` is included by default). Defaults to `priv/icons`.
* `:attributes` - A map of default attributes to inject into the SVG tags. Defaults to `%{}`.

To customize any of these values, add them to `config/config.exs`:

```elixir
config :phoenix_icon,
  base_path: "priv/static/icons",
  attributes: %{width: "24px", height: "24px"}
```
