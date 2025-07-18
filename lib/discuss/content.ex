defmodule Discuss.Content do
  @moduledoc """
  The Content context for managing discussion topics.
  """

  import Ecto.Query, warn: false
  alias Discuss.Repo
  alias Discuss.Content.Topic

  @default_per_page 10
  @max_per_page 50

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

  @doc """
  Searches for topics by title or body content.
  Returns a list of topics that match the search term.
  """
  def search_topics(term) do
    pattern = "%#{term}%"

    Topic
    |> where([t], ilike(t.title, ^pattern) or ilike(t.body, ^pattern))
    |> order_by(desc: :inserted_at)
    |> Repo.all()
  end

  @doc """
  Lists all topics with pagination support.
  Options:
    - page: page number (default: 1)
    - per_page: items per page (default: 10, max: 50)
    - sort_by: sorting field (:inserted_at, :title, :updated_at)
    - sort_order: :asc or :desc (default: :desc)
  """
  def list_topics_paginated(opts \\ []) do
    page = Keyword.get(opts, :page, 1)
    per_page = Keyword.get(opts, :per_page, @default_per_page) |> min(@max_per_page)
    sort_by = Keyword.get(opts, :sort_by, :inserted_at)
    sort_order = Keyword.get(opts, :sort_order, :desc)

    offset = (page - 1) * per_page

    query =
      Topic
      |> order_by([t], {^sort_order, field(t, ^sort_by)})
      |> limit(^per_page)
      |> offset(^offset)

    topics = Repo.all(query)
    total_count = Repo.aggregate(Topic, :count, :id)
    total_pages = ceil(total_count / per_page)

    %{
      topics: topics,
      page: page,
      per_page: per_page,
      total_count: total_count,
      total_pages: total_pages,
      has_prev: page > 1,
      has_next: page < total_pages,
      prev_page: if(page > 1, do: page - 1, else: nil),
      next_page: if(page < total_pages, do: page + 1, else: nil)
    }
  end

  @doc """
  Searches for topics with pagination support.
  """
  def search_topics_paginated(term, opts \\ []) do
    page = Keyword.get(opts, :page, 1)
    per_page = Keyword.get(opts, :per_page, @default_per_page) |> min(@max_per_page)
    sort_by = Keyword.get(opts, :sort_by, :inserted_at)
    sort_order = Keyword.get(opts, :sort_order, :desc)

    offset = (page - 1) * per_page
    pattern = "%#{term}%"

    base_query =
      Topic
      |> where([t], ilike(t.title, ^pattern) or ilike(t.body, ^pattern))

    query =
      base_query
      |> order_by([t], {^sort_order, field(t, ^sort_by)})
      |> limit(^per_page)
      |> offset(^offset)

    topics = Repo.all(query)
    total_count = Repo.aggregate(base_query, :count, :id)
    total_pages = ceil(total_count / per_page)

    %{
      topics: topics,
      page: page,
      per_page: per_page,
      total_count: total_count,
      total_pages: total_pages,
      has_prev: page > 1,
      has_next: page < total_pages,
      prev_page: if(page > 1, do: page - 1, else: nil),
      next_page: if(page < total_pages, do: page + 1, else: nil),
      term: term
    }
  end

end
