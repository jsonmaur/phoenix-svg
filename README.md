<a href="https://github.com/jsonmaur/phoenix-svg/actions/workflows/test.yml"><img alt="Test Status" src="https://img.shields.io/github/actions/workflow/status/jsonmaur/phoenix-svg/test.yml?label=&style=for-the-badge&logo=github"></a> <a href="https://hexdocs.pm/phoenix_svg/"><img alt="Hex Version" src="https://img.shields.io/hexpm/v/phoenix_svg?style=for-the-badge&label=&logo=elixir" /></a>

Use inline SVGs in your [Phoenix](https://www.phoenixframework.org) application for defining custom icon libraries. This module will load the files during compilation so you don't have to worry about performance, handle refreshing the cache when the files change, inline the SVG tags into your templates, and includes support for defining custom attributes with defaults in the config.

## Getting Started

```elixir
def deps do
  [
    {:phoenix_svg, "~> 1.0"}
  ]
end
```

The recommended way to install into your Phoenix application is to create a component file at `lib/myapp_web/components/svg.ex` (replacing `myapp` with the name of your app):

```elixir
defmodule MyAppWeb.SVG do
  use PhoenixSVG, otp_app: :myapp
end
```

This is so the files are only read and cached once. Then you can simply import `MyAppWeb.SVG` wherever you need to use the component. A good place to do this is in the `html_helpers` function in `lib/myapp_web.ex`:

```elixir
defp html_helpers do
  quote do
    # ...

    import MyAppWeb.SVG

    # ...
  end
end
```

Now when you start your Phoenix server, all the SVG files located in `priv/svgs` will be loaded into memory and can be used with the svg component. For example, if you have a file at `priv/svgs/checkmark.svg`:

```heex
<.svg name="checkmark" />
```

An error will be raised if the file is not found. If your svgs are nested in a subdirectory, specify a list in the `path` attribute with one item representing each folder. e.g. for `priv/svgs/branding/circle/checkmark.svg`:

```heex
<.svg name="checkmark" path={["branding", "circle"]} />
```

Any attributes defined will be passed through to the `<svg>` tag:

```heex
<.svg name="checkmark" class="foobar" />
```

## Configuration

* `:otp_app` - The name of your OTP application. This is required.
* `:as` - The name of the generated component function. Defaults to `:svg`.
* `:path` - The path of your svg files relative to your project directory. If using releases, make sure this path is included in your release directory (`priv` is included by default). Defaults to `priv/svgs`.
* `:attributes` - A map of default attributes to inject into the SVG tags. Defaults to `%{}`.

#### Example

```elixir
use PhoenixSVG,
  otp_app: :myapp,
  as: :icon,
  path: "priv/static/icons",
  attributes: %{width: "24px", height: "24px"}
```

```heex
<.icon name="checkmark" />
```

## Local Development

If you add, remove, or change svg files while the server is running, they will automatically be replaced in the cache and you don't have to restart for them to take effect. If you want to live reload the page when a file changes, add `~r"priv/svgs/.*(svg)$"` to the patterns list of the Endpoint config in `config/dev.exs`.
