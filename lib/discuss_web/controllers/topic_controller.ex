defmodule DiscussWeb.TopicController do
  use DiscussWeb, :controller

  alias Discuss.Content
  alias Discuss.Content.Topic

  @doc """
  GET /topics
  Lists all topics with pagination and renders the index page.
  """
  def index(conn, params) do
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
  end

  @doc """
  GET /topics/new
  Renders the form for creating a new topic.
  """
  def new(conn, _params) do
    changeset = Content.change_topic(%Topic{})
    render(conn, :new, changeset: changeset)
  end

  @doc """
  POST /topics
  Attempts to create a topic. On success, flashes and redirects to show;
  on error, re‑renders the form with errors.
  """
  def create(conn, %{"topic" => topic_params}) do
    case Content.create_topic(topic_params) do
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
    topic = Content.get_topic!(id)
    render(conn, :show, topic: topic)
  end

  @doc """
  GET /topics/:id/edit
  Renders the edit form for a topic.
  """
  def edit(conn, %{"id" => id}) do
    topic = Content.get_topic!(id)
    changeset = Content.change_topic(topic)
    render(conn, :edit, topic: topic, changeset: changeset)
  end

  @doc """
  PATCH/PUT /topics/:id
  Attempts to update a topic. On success, flashes and redirects to show;
  on error, re‑renders the edit form with errors.
  """
  def update(conn, %{"id" => id, "topic" => topic_params}) do
    topic = Content.get_topic!(id)

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
  def delete(conn, %{"id" => id}) do
    topic = Content.get_topic!(id)
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
