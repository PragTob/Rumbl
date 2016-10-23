defmodule Rumbl.Video do
  use Rumbl.Web, :model

  @primary_key {:id, Rumbl.Permalink, autogenerate: true}
  schema "videos" do
    field :url,         :string
    field :title,       :string
    field :description, :string
    field :slug,        :string

    belongs_to :user,      Rumbl.User
    belongs_to :category,  Rumbl.Category
    has_many :annotations, Rumbl.Annotation

    timestamps
  end

  @required_fields ~w(url title description)
  @optional_fields ~w(category_id)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> slugify_title()
    |> assoc_constraint(:category)
  end

  defp slugify_title(changeset) do
    changed_title = get_change(changeset, :title)
    if changed_title do
      put_change(changeset, :slug, slugify(changed_title))
    else
      changeset
    end
  end

  @non_word_characters ~r/[^\w-]+/
  defp slugify(str) do
    str
    |> String.downcase()
    |> String.replace(@non_word_characters, "-")
  end
end

defimpl Phoenix.Param, for: Rumbl.Video do
  def to_param(%{slug: slug, id: id}) do
    "#{id}-#{slug}"
  end
end
