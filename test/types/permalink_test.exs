defmodule Rumbl.PermalinkTest do
  use ExUnit.Case, async: true
  alias Rumbl.Permalink

  test "casting a sluggified link" do
    assert Permalink.cast("24-some-text") == {:ok, 24}
  end

  test "casting a normal id" do
    assert Permalink.cast(42) == {:ok, 42}
  end

  test "casting just a string id" do
    assert Permalink.cast("42") == {:ok, 42}
  end

  test "errors when handed arbitrary type" do
    assert Permalink.cast([42]) == :error
  end

  test "errors when handed pure string" do
    assert Permalink.cast("abcdefgh") == :error
  end

  test "doesn't try to be clever with numbers in strings" do
    assert Permalink.cast("Season 6") == :error
  end
end
