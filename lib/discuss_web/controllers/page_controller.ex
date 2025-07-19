defmodule DiscussWeb.PageController do
  use DiscussWeb, :controller

  # Bring in our Content context to fetch topics
  alias Discuss.Content

  @doc """
  GET /
  Renders the home page, loading the 5 most recent topics.
  """

  def home(conn, _params) do
    # fetch the latest 6 topics, ordered by insertion time descending
    topics = Content.recent_topics(6)

    # Temporarily assign current_user as nil for debugging
    conn = assign(conn, :current_user, conn.assigns[:current_user] || nil)

    # Render the home.html.heex template, passing topics: topics
    render(conn, :home, topics: topics)
  end

  def about(conn, _params) do
    # Temporarily assign current_user as nil for debugging
    conn = assign(conn, :current_user, conn.assigns[:current_user] || nil)

    # Render the about page
    render(conn, :about, page_title: "About") # We pass "About" so that <.live_title> in root.html.heex show a proper title tag
  end
end
