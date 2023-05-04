defmodule HelpersTest do
  use ExUnit.Case, async: true

  import PhoenixSVG.Helpers

  @from Path.expand("../../priv/svgs", __DIR__)

  test "list_files/1" do
    assert {[path1, path2], hash} = list_files(@from)
    assert path1 =~ "priv/svgs/account.svg"
    assert path2 =~ "priv/svgs/random/abacus.svg"
    assert byte_size(hash) == 16
  end

  describe "read_file!/1" do
    test "should get an svg with no path" do
      assert {"account", [], svg} = Path.join(@from, "account.svg") |> read_file!(@from)

      assert svg ==
               "<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 24 24\">\n  <path d=\"M12,4A4,4 0 0,1 16,8A4,4 0 0,1 12,12A4,4 0 0,1 8,8A4,4 0 0,1 12,4M12,14C16.42,14 20,15.79 20,18V20H4V18C4,15.79 7.58,14 12,14Z\" />\n</svg>"
    end

    test "should get an svg with a path" do
      assert {"abacus", ["random"], svg} = Path.join(@from, "random/abacus.svg") |> read_file!(@from)

      assert svg ==
               "<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 24 24\">\n  <path d=\"M5 5H7V11H5V5M10 5H8V11H10V5M5 19H7V13H5V19M10 13H8V19H10V17H15V15H10V13M2 21H4V3H2V21M20 3V7H13V5H11V11H13V9H20V15H18V13H16V19H18V17H20V21H22V3H20Z\" />\n</svg>"
    end

    test "should raise if svg is not found" do
      assert_raise File.Error, fn -> Path.join(@from, "invalid.svg") |> read_file!(@from) end
    end
  end

  test "to_safe_html_attrs/1" do
    assert to_safe_html_attrs(%{foo: "bar"}) == [["foo", 61, 34, "bar", 34, 32]]
    assert to_safe_html_attrs(%{f_o: "bar"}) == [["f-o", 61, 34, "bar", 34, 32]]
    assert to_safe_html_attrs(%{foo: "b>r"}) == [["foo", 61, 34, [[[], "b" | "&gt;"] | "r"], 34, 32]]

    assert to_safe_html_attrs(%{foo: "bar", baz: "qux"}) == [
             ["baz", 61, 34, "qux", 34, 32],
             ["foo", 61, 34, "bar", 34, 32]
           ]
  end
end
