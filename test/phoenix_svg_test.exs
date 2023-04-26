defmodule PhoenixSVGTest do
  use ExUnit.Case, async: true
  use PhoenixSVG, otp_app: :phoenix_svg

  import Phoenix.LiveViewTest

  @path Path.expand("../priv/svgs", __DIR__)

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

  test "list_files/1" do
    assert {[path1, path2], hash} = PhoenixSVG.list_files(@path)
    assert path1 =~ "priv/svgs/account.svg"
    assert path2 =~ "priv/svgs/random/abacus.svg"
    assert byte_size(hash) == 16
  end

  describe "read_file!/1" do
    test "should get an svg with no path" do
      assert {"account", [], svg} = Path.join(@path, "account.svg") |> PhoenixSVG.read_file!(@path)

      assert svg ==
               "<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 24 24\">\n  <path d=\"M12,4A4,4 0 0,1 16,8A4,4 0 0,1 12,12A4,4 0 0,1 8,8A4,4 0 0,1 12,4M12,14C16.42,14 20,15.79 20,18V20H4V18C4,15.79 7.58,14 12,14Z\" />\n</svg>"
    end

    test "should get an svg with a path" do
      assert {"abacus", ["random"], svg} = Path.join(@path, "random/abacus.svg") |> PhoenixSVG.read_file!(@path)

      assert svg ==
               "<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 24 24\">\n  <path d=\"M5 5H7V11H5V5M10 5H8V11H10V5M5 19H7V13H5V19M10 13H8V19H10V17H15V15H10V13M2 21H4V3H2V21M20 3V7H13V5H11V11H13V9H20V15H18V13H16V19H18V17H20V21H22V3H20Z\" />\n</svg>"
    end

    test "should raise if svg is not found" do
      assert_raise File.Error, fn -> Path.join(@path, "invalid.svg") |> PhoenixSVG.read_file!(@path) end
    end
  end

  test "to_safe_html_attrs/1" do
    assert PhoenixSVG.to_safe_html_attrs(%{foo: "bar"}) == [["foo", 61, 34, "bar", 34, 32]]
    assert PhoenixSVG.to_safe_html_attrs(%{f_o: "bar"}) == [["f-o", 61, 34, "bar", 34, 32]]
    assert PhoenixSVG.to_safe_html_attrs(%{foo: "b>r"}) == [["foo", 61, 34, [[[], "b" | "&gt;"] | "r"], 34, 32]]

    assert PhoenixSVG.to_safe_html_attrs(%{foo: "bar", baz: "qux"}) == [
             ["baz", 61, 34, "qux", 34, 32],
             ["foo", 61, 34, "bar", 34, 32]
           ]
  end
end
