defmodule Discuss.Content.Comment do
  use Ecto.Schema
  import Ecto.Changeset

  alias Discuss.Accounts.User
  alias Discuss.Content.Topic

  schema "comments" do
    field :body, :string
    belongs_to :user, User
    belongs_to :topic, Topic

    timestamps()
  end

  @doc false
  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [:body])
    |> validate_required([:body])
    |> validate_length(:body, min: 1, max: 5000)
    |> assoc_constraint(:user)
    |> assoc_constraint(:topic)
  end
end
