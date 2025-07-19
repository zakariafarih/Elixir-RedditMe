defmodule Discuss.Content do
  @moduledoc """
  The Content context for managing discussion topics.
  """

  import Ecto.Query, warn: false
  alias Discuss.Repo
  alias Discuss.Content.{Topic, Comment, Vote}
  alias Discuss.Accounts.User

  @default_per_page 10
  @max_per_page 50

  #
  # Topics
  #

  @doc """
  Returns a changeset for a new or existing topic.
  """
  def change_topic(%Topic{} = topic) do
    Topic.changeset(topic, %{})
  end

  @doc """
  Creates a new topic in the database associated with a user.
  """
  def create_topic(attrs, %Discuss.Accounts.User{} = user) do
    %Topic{}
    |> Topic.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:user, user)
    |> Repo.insert()
  end

  @doc """
  Creates a new topic without user association (for seeding).
  """
  def create_topic(attrs) do
    %Topic{}
    |> Topic.changeset(attrs)
    |> Repo.insert()
  end

  @doc "Lists all topics in the database."
  def list_topics do
    Topic
    |> preload(:user)
    |> Repo.all()
  end

  @doc "Gets a topic by ID. ( raises if not found )"
  def get_topic!(id) do
    Topic
    |> preload(:user)
    |> Repo.get!(id)
  end

  def recent_topics(limit \\ 5) do
    topics = Topic
    |> order_by(desc: :inserted_at)
    |> limit(^limit)
    |> preload(:user)
    |> Repo.all()

    # Enhance topics with comment and vote counts
    Enum.map(topics, fn topic ->
      comment_count = get_topic_comment_count(topic.id)
      vote_counts = get_topic_vote_counts(topic.id)

      topic
      |> Map.put(:comment_count, comment_count)
      |> Map.put(:vote_counts, vote_counts)
    end)
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
    |> preload(:user)
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
      |> preload(:user)

    topics = Repo.all(query)

    # Enhance topics with comment and vote counts
    topics_with_stats = Enum.map(topics, fn topic ->
      comment_count = get_topic_comment_count(topic.id)
      vote_counts = get_topic_vote_counts(topic.id)

      topic
      |> Map.put(:comment_count, comment_count)
      |> Map.put(:vote_counts, vote_counts)
    end)

    total_count = Repo.aggregate(Topic, :count, :id)
    total_pages = ceil(total_count / per_page)

    %{
      topics: topics_with_stats,
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
      |> preload(:user)

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

  #
  # Comments
  #

  @doc """
  Returns a changeset for a new comment.
  """
  def change_comment(%Comment{} = comment \\ %Comment{}) do
    Comment.changeset(comment, %{})
  end

  @doc """
  Lists comments for a specific topic with pagination.
  """
  def list_comments(topic_id, opts \\ []) do
    page = Keyword.get(opts, :page, 1)
    per_page = Keyword.get(opts, :per_page, 10)

    paginate_comments(topic_id, page: page, per_page: per_page)
  end

  @doc """
  Creates a comment associated with a user and topic.
  """
  def create_comment(%User{} = user, topic_id, attrs) do
    %Comment{}
    |> Comment.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:user, user)
    |> Ecto.Changeset.put_change(:topic_id, topic_id)
    |> Repo.insert()
  end

  @doc """
  Gets a comment by ID with user and topic preloaded.
  """
  def get_comment!(id) do
    Comment
    |> preload([:user, :topic])
    |> Repo.get!(id)
  end

  @doc """
  Updates a comment.
  """
  def update_comment(%Comment{} = comment, attrs) do
    comment
    |> Comment.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a comment.
  """
  def delete_comment(%Comment{} = comment) do
    Repo.delete(comment)
  end

  @doc """
  General paginate function with more flexibility.
  """
  def paginate(queryable, opts \\ []) do
    page = Keyword.get(opts, :page, 1)
    per_page = Keyword.get(opts, :per_page, 10) |> min(@max_per_page)

    offset = (page - 1) * per_page

    items = queryable
    |> limit(^per_page)
    |> offset(^offset)
    |> Repo.all()

    total = Repo.aggregate(queryable, :count, :id)
    total_pages = ceil(total / per_page)

    %{
      items: items,
      page: page,
      per_page: per_page,
      total: total,
      total_pages: total_pages,
      has_next: page < total_pages,
      has_prev: page > 1
    }
  end

  @doc """
  Paginates comments for a topic.
  """
  def paginate_comments(topic_id, opts \\ []) do
    page = Keyword.get(opts, :page, 1)
    per_page = min(Keyword.get(opts, :per_page, 10), @max_per_page)
    offset = (page - 1) * per_page

    # Query for fetching items with preload
    items_query =
      from c in Comment,
        where: c.topic_id == ^topic_id,
        order_by: [asc: c.inserted_at],
        preload: [:user]

    items = items_query
    |> limit(^per_page)
    |> offset(^offset)
    |> Repo.all()

    # Separate query for counting (without preload)
    total = from(c in Comment,
      where: c.topic_id == ^topic_id,
      select: count(c.id)
    )
    |> Repo.one()

    %{
      items: items,
      page: page,
      per_page: per_page,
      total: total,
      has_next: (page * per_page) < total,
      has_prev: page > 1
    }
  end

  #
  # Votes
  #

  @doc """
  Creates or updates a vote for a topic by a user.
  If the user already voted with the same type, removes the vote.
  If the user voted differently, updates the vote.
  """
  def vote_topic(user, topic_id, vote_type) when vote_type in [:upvote, :downvote] do
    case get_user_vote(user.id, topic_id) do
      nil ->
        # No existing vote, create new one
        %Vote{}
        |> Vote.changeset(%{user_id: user.id, topic_id: topic_id, vote_type: vote_type})
        |> Repo.insert()

      existing_vote ->
        if existing_vote.vote_type == vote_type do
          # Same vote type, remove the vote
          Repo.delete(existing_vote)
        else
          # Different vote type, update the vote
          existing_vote
          |> Vote.changeset(%{vote_type: vote_type})
          |> Repo.update()
        end
    end
  end

  @doc """
  Gets a user's vote for a specific topic.
  """
  def get_user_vote(user_id, topic_id) do
    Repo.get_by(Vote, user_id: user_id, topic_id: topic_id)
  end

  @doc """
  Gets vote counts for a topic.
  Returns %{upvotes: count, downvotes: count, total: count}
  """
  def get_topic_vote_counts(topic_id) do
    votes = from(v in Vote, where: v.topic_id == ^topic_id, select: v.vote_type) |> Repo.all()

    upvotes = Enum.count(votes, &(&1 == :upvote))
    downvotes = Enum.count(votes, &(&1 == :downvote))

    %{
      upvotes: upvotes,
      downvotes: downvotes,
      total: upvotes - downvotes
    }
  end

  @doc """
  Gets comment count for a topic.
  """
  def get_topic_comment_count(topic_id) do
    from(c in Comment, where: c.topic_id == ^topic_id, select: count(c.id))
    |> Repo.one()
  end

  @doc """
  Gets latest comments for a topic (for display on topic show page).
  """
  def get_latest_comments(topic_id, limit \\ 3) do
    from(c in Comment,
      where: c.topic_id == ^topic_id,
      order_by: [desc: c.inserted_at],
      limit: ^limit,
      preload: [:user]
    )
    |> Repo.all()
  end
end
