defmodule Rumbl.UserRepoTest do
  use Rumbl.ModelCase
  alias Rumbl.User

  @valid_attrs %{name: "Homer", username: "Homer"}

  test "convert uniqueness constraint on username to error" do
    insert_user(username: "Homer")
    attrs = Map.put @valid_attrs, :username, "Homer"
    changeset = User.new_changeset %User{}, attrs

    assert {:error, changeset} = Repo.insert changeset
    assert {:username, "has already been taken"} in changeset.errors
  end
end
