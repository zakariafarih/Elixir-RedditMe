defmodule DiscussWeb.TopicController do
  use DiscussWeb, :controller

  alias Discuss.Content
  alias Discuss.Content.Topic

  # Authorization plug for actions that require ownership
  plug :authorize_topic when action in [:edit, :update, :delete]

  defp authorize_topic(%{params: %{"id" => id}} = conn, _opts) do
    topic = Content.get_topic!(id)
    if topic.user_id == conn.assigns.current_user.id do
      assign(conn, :topic, topic)   # reuse loaded topic
    else
      conn
      |> put_flash(:error, "Not authorized")
      |> redirect(to: ~p"/topics")
      |> halt()
    end
  end

  @doc """
  GET /topics
  Lists all topics with pagination and renders the index page.
  """
  def index(conn, params) do
    # Redirect to login if user is not authenticated
    if conn.assigns[:current_user] do
      page = String.to_integer(Map.get(params, "page", "1"))
      per_page = String.to_integer(Map.get(params, "per_page", "10"))
      sort_by = String.to_existing_atom(Map.get(params, "sort_by", "inserted_at"))
      sort_order = String.to_existing_atom(Map.get(params, "sort_order", "desc"))

      pagination = Content.list_topics_paginated([
        page: page,
        per_page: per_page,
        sort_by: sort_by,
        sort_order: sort_order
      ])

      render(conn, :index,
        topics: pagination.topics,
        pagination: pagination,
        current_sort: sort_by,
        current_order: sort_order,
        params: params
      )
    else
      conn
      |> put_flash(:error, "You must be logged in to browse topics.")
      |> redirect(to: ~p"/users/log_in")
    end
  end

  @doc """
  GET /topics/new
  Renders the form for creating a new topic.
  """
  def new(conn, _params) do
    # Check if user is authenticated
    if conn.assigns[:current_user] do
      changeset = Content.change_topic(%Topic{})
      render(conn, :new, changeset: changeset)
    else
      conn
      |> put_flash(:error, "You must be logged in to create a topic.")
      |> redirect(to: ~p"/users/log_in")
    end
  end

  @doc """
  POST /topics
  Attempts to create a topic. On success, flashes and redirects to show;
  on error, re‑renders the form with errors.
  """
  def create(conn, %{"topic" => topic_params}) do
    case Content.create_topic(topic_params, conn.assigns.current_user) do
      {:ok, topic} ->
        conn
        |> put_flash(:info, "Topic created successfully!")
        |> redirect(to: ~p"/topics/#{topic.id}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  @doc """
  GET /topics/:id
  Shows a single topic.
  """
  def show(conn, %{"id" => id}) do
    # Redirect to login if user is not authenticated
    if conn.assigns[:current_user] do
      topic = Content.get_topic!(id)
      current_user = conn.assigns.current_user

      # Get vote and comment stats
      vote_counts = Content.get_topic_vote_counts(topic.id)
      comment_count = Content.get_topic_comment_count(topic.id)
      latest_comments = Content.get_latest_comments(topic.id, 3)

      # Get current user's vote if logged in
      user_vote = Content.get_user_vote(current_user.id, topic.id)

      render(conn, :show,
        topic: topic,
        vote_counts: vote_counts,
        comment_count: comment_count,
        latest_comments: latest_comments,
        user_vote: user_vote
      )
    else
      conn
      |> put_flash(:error, "You must be logged in to view topics.")
      |> redirect(to: ~p"/users/log_in")
    end
  end

  @doc """
  POST /topics/:id/vote
  Handles voting on a topic (upvote/downvote).
  """
  def vote(conn, %{"id" => id, "vote_type" => vote_type}) do
    current_user = conn.assigns.current_user

    unless current_user do
      conn
      |> put_flash(:error, "You must be logged in to vote")
      |> redirect(to: ~p"/topics/#{id}")
    else
      vote_atom = String.to_existing_atom(vote_type)

      case Content.vote_topic(current_user, id, vote_atom) do
        {:ok, _vote} ->
          conn
          |> put_flash(:info, "Vote recorded!")
          |> redirect(to: ~p"/topics/#{id}")

        {:error, _changeset} ->
          conn
          |> put_flash(:error, "Unable to record vote")
          |> redirect(to: ~p"/topics/#{id}")
      end
    end
  end

  @doc """
  GET /topics/:id/edit
  Renders the edit form for a topic.
  """
  def edit(conn, _params) do
    topic = conn.assigns.topic
    changeset = Content.change_topic(topic)
    render(conn, :edit, topic: topic, changeset: changeset)
  end

  @doc """
  PATCH/PUT /topics/:id
  Attempts to update a topic. On success, flashes and redirects to show;
  on error, re‑renders the edit form with errors.
  """
  def update(conn, %{"topic" => topic_params}) do
    topic = conn.assigns.topic

    case Content.update_topic(topic, topic_params) do
      {:ok, topic} ->
        conn
        |> put_flash(:info, "Topic updated successfully!")
        |> redirect(to: ~p"/topics/#{topic.id}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, topic: topic, changeset: changeset)
    end
  end

  @doc """
  DELETE /topics/:id
  Deletes the topic and redirects back to the list.
  """
  def delete(conn, _params) do
    topic = conn.assigns.topic
    {:ok, _} = Content.delete_topic(topic)

    conn
    |> put_flash(:info, "Topic deleted successfully!")
    |> redirect(to: ~p"/topics")
  end

  @doc """
  GET /topics/search
  Searches for topics with pagination based on a query term.
  """
  def search(conn, %{"q" => term} = params) do
    page = String.to_integer(Map.get(params, "page", "1"))
    per_page = String.to_integer(Map.get(params, "per_page", "10"))
    sort_by = String.to_existing_atom(Map.get(params, "sort_by", "inserted_at"))
    sort_order = String.to_existing_atom(Map.get(params, "sort_order", "desc"))

    pagination = Content.search_topics_paginated(term, [
      page: page,
      per_page: per_page,
      sort_by: sort_by,
      sort_order: sort_order
    ])

    render(conn, :search,
      results: pagination.topics,
      pagination: pagination,
      current_sort: sort_by,
      current_order: sort_order,
      term: term,
      params: params
    )
  end

  def search(conn, _params) do
    # Redirect to topics index if no search term provided
    redirect(conn, to: ~p"/topics")
  end
end
