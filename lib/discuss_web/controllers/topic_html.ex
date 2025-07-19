defmodule DiscussWeb.TopicHTML do
  @moduledoc """
  This module contains pages rendered by TopicController.

  See the `topic_html` directory for all templates available.
  """
  use DiscussWeb, :html

  embed_templates "topic_html/*"

  @doc """
  Renders a topic card component for displaying topics in lists.
  """
  def topic_card(assigns) do
    ~H"""
    <div class="bg-white rounded-2xl overflow-hidden shadow-sm hover:shadow-lg transition-shadow duration-200 border border-gray-100">
      <div class="p-6">
        <div class="flex items-center justify-between mb-4">
          <div class="flex items-center space-x-2">
            <div class="w-8 h-8 rounded-full bg-gradient-to-r from-indigo-500 to-purple-500 flex items-center justify-center">
              <span class="text-xs font-bold text-white">
                <%= if @topic.user do %>
                  <%= String.first(Discuss.Accounts.User.username(@topic.user)) |> String.upcase() %>
                <% else %>
                  ?
                <% end %>
              </span>
            </div>
            <div class="flex flex-col">
              <span class="text-sm text-gray-500">
                Posted <%= format_date(@topic.inserted_at) %>
              </span>
              <%= if @topic.user do %>
                <span class="text-xs text-gray-400">
                  by <%= Discuss.Accounts.User.username(@topic.user) %>
                </span>
              <% end %>
            </div>
          </div>
          <span class="px-3 py-1 bg-indigo-100 text-indigo-800 text-xs font-medium rounded-full">
            Topic #<%= @topic.id %>
          </span>
        </div>

        <h2 class="text-xl font-semibold text-gray-900 mb-3 hover:text-indigo-700 transition-colors">
          <.link navigate={~p"/topics/#{@topic.id}"}><%= @topic.title %></.link>
        </h2>

        <p class="text-gray-600 text-sm line-clamp-3 mb-4">
          <%= if @topic.body && String.length(@topic.body) > 0 do %>
            <%= String.slice(@topic.body, 0, 150) %><%= if String.length(@topic.body) > 150, do: "..." %>
          <% else %>
            <span class="italic text-gray-400">No description provided.</span>
          <% end %>
        </p>

        <div class="flex justify-between items-center">
          <%= if assigns[:current_user] do %>
            <.link
              navigate={~p"/topics/#{@topic.id}"}
              class="inline-flex items-center px-4 py-2 bg-gradient-to-r from-indigo-600 to-purple-600 text-white font-medium rounded-lg hover:from-indigo-700 hover:to-purple-700 transition-all duration-200 text-sm shadow-sm"
            >
              <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/>
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"/>
              </svg>
              View Topic
            </.link>
          <% else %>
            <.link
              navigate={~p"/users/log_in"}
              class="inline-flex items-center px-4 py-2 bg-gradient-to-r from-indigo-600 to-purple-600 text-white font-medium rounded-lg hover:from-indigo-700 hover:to-purple-700 transition-all duration-200 text-sm shadow-sm"
            >
              <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 16l-4-4m0 0l4-4m-4 4h14m-5 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h7a3 3 0 013 3v1" />
              </svg>
              Sign in to view
            </.link>
          <% end %>

          <div class="flex items-center space-x-4">
            <%= if assigns[:current_user] && @topic.user_id && @current_user.id == @topic.user_id do %>
              <.link
                navigate={~p"/topics/#{@topic.id}/edit"}
                class="inline-flex items-center text-gray-500 hover:text-indigo-600 transition-colors text-sm"
              >
                <svg class="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"/>
                </svg>
                Edit
              </.link>

              <.link
                href={~p"/topics/#{@topic.id}"}
                method="delete"
                data-confirm="Are you sure you want to delete this topic?"
                class="inline-flex items-center text-gray-500 hover:text-red-600 transition-colors text-sm"
              >
                <svg class="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"/>
                </svg>
                Delete
              </.link>
            <% end %>

            <div class="flex space-x-2">
              <span class="inline-flex items-center text-gray-500 text-sm">
                <svg class="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 8h10M7 12h4m1 8l-4-4H5a2 2 0 01-2-2V6a2 2 0 012-2h14a2 2 0 012 2v8a2 2 0 01-2 2h-3l-4 4z"/>
                </svg>
                <%= Map.get(@topic, :comment_count, 0) %>
              </span>
              <span class="inline-flex items-center text-gray-500 text-sm">
                <svg class="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 11l5-5m0 0l5 5m-5-5v12"/>
                </svg>
                <%= Map.get(@topic, :vote_counts, %{}) |> Map.get(:total, 0) %>
              </span>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def form_component(assigns) do
    ~H"""
    <div class="bg-white rounded-2xl shadow-xl overflow-hidden">
      <div class="bg-gradient-to-r from-indigo-600 to-purple-600 px-8 py-6">
        <h2 class="text-2xl font-bold text-white">
          <%= if @changeset.data.id, do: "Update Your Topic", else: "Share Your Ideas" %>
        </h2>
        <p class="text-indigo-100 mt-1">
          <%= if @changeset.data.id, do: "Make changes to your topic", else: "Start a new discussion in our community" %>
        </p>
      </div>

      <div class="p-8">
        <.simple_form :let={f} for={@changeset} id="topic-form" action={@action} class="space-y-6">
          <div class="space-y-2">
            <.input
              field={f[:title]}
              label="Topic Title"
              class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 transition-colors"
              placeholder="What would you like to discuss?"
            />
            <p class="text-sm text-gray-500">Choose a clear, descriptive title for your topic</p>
          </div>

          <div class="space-y-2">
            <label class="block text-sm font-medium text-gray-700 mb-2">
              Topic Content
            </label>
            <textarea
              name="topic[body]"
              id="topic_body"
              data-markdown-editor="true"
              data-max-length="10000"
              data-show-word-count="true"
              data-show-cheat-sheet="true"
              placeholder="Share your thoughts, ask questions, or start a discussion..."
              class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 transition-colors resize-none"
              rows="12"
            ><%= if @changeset.data.body, do: @changeset.data.body %></textarea>

            <!-- Display validation errors for body field -->
            <%= if @changeset.action && Keyword.has_key?(@changeset.errors, :body) do %>
              <div class="text-red-600 text-sm mt-1">
                <%= for {msg, _} <- Keyword.get_values(@changeset.errors, :body) do %>
                  <div class="flex items-center">
                    <svg class="w-4 h-4 mr-1" fill="currentColor" viewBox="0 0 20 20">
                      <path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7 4a1 1 0 11-2 0 1 1 0 012 0zm-1-9a1 1 0 00-1 1v4a1 1 0 102 0V6a1 1 0 00-1-1z" clip-rule="evenodd"/>
                    </svg>
                    <%= msg %>
                  </div>
                <% end %>
              </div>
            <% end %>

            <p class="text-sm text-gray-500">Support for Markdown formatting available. Maximum 10,000 characters.</p>
          </div>

          <:actions>
            <div class="flex items-center justify-between pt-6 border-t border-gray-200">
              <div class="flex space-x-3">
                <%= if @changeset.data.id do %>
                  <.link
                    navigate={~p"/topics/#{@changeset.data.id}"}
                    class="inline-flex items-center px-4 py-2 border border-gray-300 text-gray-700 bg-white rounded-lg hover:bg-gray-50 focus:ring-2 focus:ring-indigo-500 transition-colors"
                  >
                    <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                    </svg>
                    Cancel
                  </.link>
                <% else %>
                  <.link
                    navigate={~p"/topics"}
                    class="inline-flex items-center px-4 py-2 border border-gray-300 text-gray-700 bg-white rounded-lg hover:bg-gray-50 focus:ring-2 focus:ring-indigo-500 transition-colors"
                  >
                    <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18" />
                    </svg>
                    Back to Topics
                  </.link>
                <% end %>
              </div>

              <div class="ml-6">
                <.button
                  type="submit"
                  class="inline-flex items-center px-6 py-3 bg-gradient-to-r from-indigo-600 to-purple-600 text-white font-semibold rounded-lg hover:from-indigo-700 hover:to-purple-700 focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2 shadow-lg hover:shadow-xl transform hover:scale-105 transition-all duration-200"
                >
                  <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <%= if @changeset.data.id do %>
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" />
                    <% else %>
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6" />
                    <% end %>
                  </svg>
                  <%= if @changeset.data.id, do: "Update Topic", else: "Create Topic" %>
                </.button>
              </div>
            </div>
          </:actions>
        </.simple_form>
      </div>
    </div>
    """
  end

  @doc """
  Format a datetime into a human-friendly string.
  """
  def format_date(datetime) do
    Calendar.strftime(datetime, "%b %d, %Y")
  end
end
