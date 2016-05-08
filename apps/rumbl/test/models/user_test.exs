defmodule Rumbl.UserTest do
  use Rumbl.ModelCase, async: true
  alias Rumbl.User

  @valid_attrs %{name: "Homer Simpson", username: "Homer", password: "secret"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = User.new_changeset %User{}, @valid_attrs
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = User.new_changeset %User{}, @invalid_attrs
    refute changeset.valid?
  end

  test "changeset does not accept long usernames" do
    attrs = Map.put @valid_attrs, :username, String.duplicate("a", 21)
    changeset = User.new_changeset %User{}, attrs
    assert {:username, {"should be at most %{count} character(s)", [count: 20]}} in changeset.errors
  end

  test "registration_changeset password must be at least 6 chars" do
    attrs = Map.put @valid_attrs, :password, "12345"
    changeset = User.registration_changeset %User{}, attrs
    assert {:password, {"should be at least %{count} character(s)", [count: 6]}} in changeset.errors
  end

  test "registration_changeset hashes valid password" do
    attrs = Map.put @valid_attrs, :password, "123456"
    changeset = User.registration_changeset %User{}, attrs

    assert changeset.valid?

    %{password: pass, password_hash: hash} = changeset.changes
    assert hash
    assert Comeonin.Bcrypt.checkpw(pass, hash)
  end
end
