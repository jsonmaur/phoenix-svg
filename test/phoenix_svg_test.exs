defmodule PhoenixSVGTest do
  use ExUnit.Case, async: true
  use PhoenixSVG, otp_app: :phoenix_svg

  import Phoenix.LiveViewTest

  describe "svg/1" do
    test "should render an svg" do
      html = render_component(&svg/1, name: "account")

      refute html =~ "name="
      refute html =~ "path="

      assert html =~ " viewBox=\"0 0 24 24\""
      assert html =~ " d=\"M12"
    end

    test "should render an svg with path" do
      html = render_component(&svg/1, name: "abacus", path: ["random"])

      refute html =~ "name="
      refute html =~ "path="

      assert html =~ " viewBox=\"0 0 24 24\""
      assert html =~ " d=\"M5"
    end

    test "should render an svg with assigns" do
      html = render_component(&svg/1, name: "account", width: "48px", class: "foobar")

      refute html =~ "name="
      refute html =~ "path="
      refute html =~ "width=\"24px\""

      assert html =~ " width=\"48px\""
      assert html =~ " class=\"foobar\""
      assert html =~ " viewBox=\"0 0 24 24\""
      assert html =~ " d=\"M12"
    end

    test "should raise for an svg that does not exist" do
      assert_raise RuntimeError, "\"invalid\" is not a valid svg", fn ->
        render_component(&svg/1, name: "invalid")
      end
    end

    test "should raise for a path that does not exist" do
      assert_raise RuntimeError, "\"invalid\" is not a valid svg for path \"[\"invalidpath\"]\"", fn ->
        render_component(&svg/1, name: "invalid", path: ["invalidpath"])
      end
    end
  end

  describe "icon/1" do
    use PhoenixSVG, otp_app: :phoenix_svg, as: :icon, from: "priv/svgs/random", attributes: [width: "24px"]

    test "should render an icon" do
      html = render_component(&icon/1, name: "abacus")

      refute html =~ "name="
      refute html =~ "path="

      assert html =~ " width=\"24px\""
      assert html =~ " viewBox=\"0 0 24 24\""
      assert html =~ " d=\"M5"
    end
  end
end
