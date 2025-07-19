defmodule Discuss.Content.Vote do
  use Ecto.Schema
  import Ecto.Changeset

  schema "votes" do
    field :vote_type, Ecto.Enum, values: [:upvote, :downvote]
    belongs_to :user, Discuss.Accounts.User
    belongs_to :topic, Discuss.Content.Topic

    timestamps()
  end

  @doc false
  def changeset(vote, attrs) do
    vote
    |> cast(attrs, [:vote_type, :user_id, :topic_id])
    |> validate_required([:vote_type, :user_id, :topic_id])
    |> validate_inclusion(:vote_type, [:upvote, :downvote])
    |> unique_constraint([:user_id, :topic_id], message: "You can only vote once per topic")
  end
end
