defmodule DiscussWeb.PageHTML do
  @moduledoc """
  This module contains pages rendered by PageController.

  See the `page_html` directory for all templates available.
  """
  use DiscussWeb, :html
  import DiscussWeb.TopicHTML, only: [topic_card: 1]

  embed_templates "page_html/*"
end
