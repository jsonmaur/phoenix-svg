<a href="https://github.com/jsonmaur/phoenix-icon/actions/workflows/test.yml"><img alt="Test Status" src="https://img.shields.io/github/actions/workflow/status/jsonmaur/phoenix-icon/test.yml?label=&style=for-the-badge&logo=github"></a> <a href="https://hexdocs.pm/phoenix_icon/"><img alt="Hex Version" src="https://img.shields.io/hexpm/v/phoenix_icon?style=for-the-badge&label=&logo=elixir" /></a>

Use a folder of SVGs for icons in your Phoenix application. This library will load the files during compilation so you don't have to worry about performance, inline the SVG tags into your templates, and includes support for defining custom attributes with defaults in the config.

## Getting Started

```elixir
def deps do
  [
    {:phoenix_icon, "~> 1.0"}
  ]
end
```

The recommended way to install into your Phoenix application is to create a component file at `lib/myapp_web/components/icon.ex` (replacing `myapp` with the name of your app):

```elixir
defmodule MyAppWeb.Icon do
  use PhoenixIcon, otp_app: :myapp
end
```

This is so the icons are only read and cached once. Then you can simply import `MyAppWeb.Icon` wherever you need to use the icon component. A good place to do this is in the `html_helpers` function in `lib/myapp_web.ex`:

```elixir
defp html_helpers do
  quote do

    # If you're using the Core components that come with a new Phoenix installation,
    # exclude the `icon` component to avoid a function naming conflict.
    import MyAppWeb.CoreComponents, except: [icon: 1]
    import MyAppWeb.Icon

  end
end
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

## Local Development

If you add, remove, or change icon files while the server is running, they will automatically be replaced in the cache and you don't have to restart for them to take effect. If you want to live reload the page when an icon file changes, add `~r"priv/icons/.*(svg)$"` to the patterns list of the Endpoint config in `config/dev.exs`.
