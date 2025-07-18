defmodule DiscussWeb.TopicHTML do
  @moduledoc """
  This module contains pages rendered by TopicController.

  See the `topic_html` directory for all templates available.
  """
  use DiscussWeb, :html

  embed_templates "topic_html/*"

  def form_component(assigns) do
    ~H"""
    <.simple_form :let={f} for={@form} id="topic-form" action={@action}>
      <.input field={f[:title]} label="Title" />
      <.input field={f[:body]} label="Body" type="textarea" />

      <:actions>
        <.button type="submit">
          <%= if @form.data.id, do: "Update Topic", else: "Create Topic" %>
        </.button>

        <%= if @form.data.id do %>
          <.link navigate={~p"/topics/#{@form.data.id}"} class="ml-4 text-sm text-gray-600 hover:underline">
            Cancel
          </.link>
        <% else %>
          <.link navigate={~p"/topics"} class="ml-4 text-sm text-gray-600 hover:underline">
            Back to Topics
          </.link>
        <% end %>
      </:actions>
    </.simple_form>
    """
  end
end
