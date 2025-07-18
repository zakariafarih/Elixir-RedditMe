defmodule Discuss.Content do
  @moduledoc """
  The Content context for managing discussion topics.
  """

  import Ecto.Query, warn: false
  alias Discuss.Repo
  alias Discuss.Content.Topic

  @doc """
  Returns a changeset for a new or existing topic.
  """
  def change_topic(%Topic{} = topic) do
    Topic.changeset(topic, %{})
  end

  @doc """
  Creates a new topic in the database.
  """
  def create_topic(attrs \\ %{}) do
    %Topic{}
    |> Topic.changeset(attrs)
    |> Repo.insert()
  end

  @doc "Lists all topics in the database."
  def list_topics do
    Repo.all(Topic)
  end

  @doc "Gets a topic by ID. ( raises if not found )"
  def get_topic!(id), do: Repo.get!(Topic, id)

  def recent_topics(limit \\ 5) do
    Topic
    |> order_by(desc: :inserted_at)
    |> limit(^limit)
    |> Repo.all()
  end

  @doc "Updates an existing topic"
  def update_topic(%Topic{} = topic, attrs) do
    topic
    |> Topic.changeset(attrs)
    |> Repo.update()
  end

  @doc "Deletes a topic"
  def delete_topic(%Topic{} = topic) do
    Repo.delete(topic)
  end

end
