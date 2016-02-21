defmodule Rumbl.User do
  use Rumbl.Web, :model

  schema "users" do
    field :name,          :string
    field :username,      :string
    field :password,      :string, virtual: true
    field :password_hash, :string

    timestamps
  end

  def new_changeset(model, params \\ :empty) do
    model
    |> cast(params, ~w(name username), [])
    |> unique_constraint(:username)
    |> validate_length(:username, min: 1, max: 20)
  end
end
