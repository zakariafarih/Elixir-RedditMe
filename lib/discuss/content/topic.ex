defmodule Discuss.Content.Topic do
  use Ecto.Schema
  import Ecto.Changeset

  schema "topics" do
    field :title, :string
    field :body, :string
    # We just add this association for now, Waiting for next milestone to implement User authentication fully
    belongs_to :user, Discuss.Accounts.User
    timestamps()
  end

  @doc false
  def changeset(topic, attrs) do
    topic
    |> cast(attrs, [:title, :body])
    |> validate_required([:title, :body])
    |> validate_length(:title, min: 3, max: 200)
    |> validate_length(:body, min: 10, max: 10000)
  end
end
