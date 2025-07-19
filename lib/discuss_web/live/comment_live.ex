defmodule DiscussWeb.CommentLive do
  use DiscussWeb, :live_view

  alias Discuss.Content
  alias Phoenix.PubSub
  alias DiscussWeb.Presence

  # Mount the current user using Phoenix authentication
  on_mount {DiscussWeb.UserAuth, :mount_current_user}

  @impl true
  def mount(%{"topic_id" => topic_id}, _session, socket) do
    topic = Content.get_topic!(topic_id)

    # Get current user from socket assigns (set by on_mount hook)
    current_user = socket.assigns.current_user

    if connected?(socket) do
      # Subscribe to real-time comment updates for this topic
      topic_presence_key = "comments:#{topic.id}"
      PubSub.subscribe(Discuss.PubSub, topic_presence_key)

      # Track presence if user is logged in
      if current_user do
        {:ok, _} = Presence.track(self(), topic_presence_key, current_user.id, %{
          typing: false,
          username: Discuss.Accounts.User.username(current_user),
          joined_at: System.system_time(:second)
        })
      end
    end

    # Load initial comments
    comments_data = Content.list_comments(topic.id, page: 1, per_page: 10)
    comment_changeset = Content.change_comment()

    # Get initial presence list
    presence_list = if connected?(socket) do
      Presence.list("comments:#{topic.id}")
    else
      %{}
    end

    socket =
      socket
      |> assign(:topic, topic)
      |> assign(:current_user, current_user)
      |> stream(:comments, comments_data.items)
      |> assign(:comments_pagination, comments_data)
      |> assign(:comment_changeset, comment_changeset)
      |> assign(:form, to_form(comment_changeset))
      |> assign(:typing_users, get_typing_users(presence_list, current_user))

    {:ok, socket}
  end

  @impl true
  def handle_event("submit_comment", %{"comment" => comment_params}, socket) do
    %{topic: topic, current_user: current_user} = socket.assigns

    if current_user do
      # Temporarily disable rate limiting for testing
      # case check_rate_limit(current_user.id, topic.id) do
      #   :ok ->
          # Sanitize the comment body
          sanitized_params = sanitize_comment_params(comment_params)

          case Content.create_comment(current_user, topic.id, sanitized_params) do
            {:ok, comment} ->
              # Broadcast the new comment to all subscribers
              comment_with_user = Content.get_comment!(comment.id)
              PubSub.broadcast(Discuss.PubSub, "comments:#{topic.id}",
                {:new_comment, comment_with_user})

              # Add to stream and reset form
              new_changeset = Content.change_comment()
              socket =
                socket
                |> stream_insert(:comments, comment_with_user, at: 0)
                |> assign(:comment_changeset, new_changeset)
                |> assign(:form, to_form(new_changeset))
                |> push_event("clear-comment-form", %{})
                |> put_flash(:info, "Comment added!")

              {:noreply, socket}

            {:error, changeset} ->
              socket =
                socket
                |> assign(:comment_changeset, changeset)
                |> assign(:form, to_form(changeset))
                |> put_flash(:error, "Failed to add comment")

              {:noreply, socket}
          end
        # :rate_limited ->
        #   {:noreply, put_flash(socket, :error, "Please wait before posting another comment")}
      # end
    else
      {:noreply, put_flash(socket, :error, "You must be logged in to comment")}
    end
  end

  @impl true
  def handle_event("typing", _params, socket) do
    %{topic: topic, current_user: current_user} = socket.assigns

    if current_user do
      # Update presence with typing status
      topic_presence_key = "comments:#{topic.id}"
      {:ok, _} = Presence.update(self(), topic_presence_key, current_user.id, %{
        typing: true,
        username: Discuss.Accounts.User.username(current_user),
        joined_at: System.system_time(:second)
      })
    end

    {:noreply, socket}
  end

  @impl true
  def handle_event("stop_typing", _params, socket) do
    %{topic: topic, current_user: current_user} = socket.assigns

    if current_user do
      # Update presence to stop typing
      topic_presence_key = "comments:#{topic.id}"
      {:ok, _} = Presence.update(self(), topic_presence_key, current_user.id, %{
        typing: false,
        username: Discuss.Accounts.User.username(current_user),
        joined_at: System.system_time(:second)
      })
    end

    {:noreply, socket}
  end

  @impl true
  def handle_event("load_more", _params, socket) do
    %{topic: topic, comments_pagination: pagination} = socket.assigns

    next_page = pagination.page + 1
    next_comments_data = Content.list_comments(topic.id, page: next_page, per_page: 10)

    socket =
      socket
      |> stream(:comments, next_comments_data.items)
      |> assign(:comments_pagination, next_comments_data)

    {:noreply, socket}
  end

  @impl true
  def handle_info({:new_comment, comment}, socket) do
    # Only add comment if it's from another user (current user's comments are added directly in submit_comment)
    current_user = socket.assigns.current_user
    if current_user && comment.user_id == current_user.id do
      # This is the current user's comment, it should already be in the stream from submit_comment
      {:noreply, socket}
    else
      # This is from another user, add it to the stream
      socket = stream_insert(socket, :comments, comment, at: 0)
      {:noreply, socket}
    end
  end

  @impl true
  def handle_info(%{event: "presence_diff", payload: _diff}, socket) do
    # Handle presence changes for typing indicators
    current_user = socket.assigns.current_user
    presence_list = Presence.list("comments:#{socket.assigns.topic.id}")
    typing_users = get_typing_users(presence_list, current_user)

    {:noreply, assign(socket, :typing_users, typing_users)}
  end

  @impl true
  def handle_info({:user_typing, %{user_id: _user_id, username: _username}}, socket) do
    # This is handled by presence now
    {:noreply, socket}
  end

  @impl true
  def handle_info({:user_stop_typing, %{user_id: _user_id}}, socket) do
    # This is handled by presence now
    {:noreply, socket}
  end

  @impl true
  def handle_info({:remove_typing, _username}, socket) do
    # This is handled by presence now
    {:noreply, socket}
  end

  # Helper function to extract typing users from presence
  defp get_typing_users(presence_list, current_user) do
    for {_user_id, %{metas: metas}} <- presence_list,
        meta <- metas,
        meta.typing == true,
        !current_user || meta.username != Discuss.Accounts.User.username(current_user) do
      meta.username
    end
  end

  # Simple rate limiting using process dictionary
  defp check_rate_limit(user_id, topic_id) do
    key = "rate_limit_#{user_id}_#{topic_id}"
    last_comment_time = Process.get(key, 0)
    current_time = System.system_time(:second)

    if current_time - last_comment_time >= 2 do # 2 seconds cooldown (reduced from 10)
      Process.put(key, current_time)
      :ok
    else
      :rate_limited
    end
  end

  # Sanitize comment parameters
  defp sanitize_comment_params(%{"body" => body} = params) do
    # Basic HTML sanitization - remove potentially dangerous tags and scripts
    sanitized_body = body
    |> String.replace(~r/<script[^>]*>.*?<\/script>/is, "")
    |> String.replace(~r/<iframe[^>]*>.*?<\/iframe>/is, "")
    |> String.replace(~r/<object[^>]*>.*?<\/object>/is, "")
    |> String.replace(~r/<embed[^>]*>/i, "")
    |> String.replace(~r/<link[^>]*>/i, "")
    |> String.replace(~r/<meta[^>]*>/i, "")
    |> String.replace(~r/javascript:/i, "")
    |> String.replace(~r/on\w+\s*=/i, "")
    |> String.trim()

    Map.put(params, "body", sanitized_body)
  end

  defp sanitize_comment_params(params), do: params

  # Helper function for date formatting
  defp format_relative_time(datetime) do
    now = DateTime.utc_now()

    # Convert NaiveDateTime to DateTime if needed
    datetime = case datetime do
      %NaiveDateTime{} -> DateTime.from_naive!(datetime, "Etc/UTC")
      %DateTime{} -> datetime
    end

    diff_seconds = DateTime.diff(now, datetime, :second)

    cond do
      diff_seconds < 60 -> "just now"
      diff_seconds < 3600 -> "#{div(diff_seconds, 60)}m ago"
      diff_seconds < 86400 -> "#{div(diff_seconds, 3600)}h ago"
      diff_seconds < 604800 -> "#{div(diff_seconds, 86400)}d ago"
      true ->
        datetime
        |> DateTime.to_date()
        |> Date.to_string()
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="bg-white rounded-2xl shadow-lg overflow-hidden">
      <div class="border-b border-gray-200 p-6">
        <h2 class="text-xl font-bold text-gray-900 flex items-center">
          <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z" />
          </svg>
          Comments
          <span class="ml-2 text-sm font-normal text-gray-500">(<%= @comments_pagination.total %>)</span>
        </h2>
      </div>

      <!-- Comments List -->
      <div id="comments-list" phx-update="stream" class="divide-y divide-gray-200">
        <%= if @comments_pagination.total > 0 do %>
          <div :for={{dom_id, comment} <- @streams.comments} id={dom_id} class="p-6 hover:bg-gray-50 transition-colors duration-200">
            <div class="flex items-start space-x-4">
              <!-- User Avatar -->
              <div class="w-10 h-10 rounded-full bg-gradient-to-br from-indigo-500 to-purple-600 flex items-center justify-center shadow-sm flex-shrink-0">
                <span class="text-sm font-bold text-white">
                  <%= String.first(Discuss.Accounts.User.username(comment.user)) |> String.upcase() %>
                </span>
              </div>

              <!-- Comment Content -->
              <div class="flex-1 min-w-0">
                <div class="flex items-center justify-between mb-2">
                  <div class="flex items-center space-x-2">
                    <span class="font-medium text-gray-900">
                      <%= Discuss.Accounts.User.username(comment.user) %>
                    </span>
                    <span class="text-sm text-gray-500">
                      <%= format_relative_time(comment.inserted_at) %>
                    </span>
                  </div>

                  <%= if @current_user && comment.user_id == @current_user.id do %>
                    <div class="flex items-center space-x-2">
                      <.link
                        href={~p"/topics/#{@topic.id}/comments/#{comment.id}/edit"}
                        class="text-gray-400 hover:text-indigo-600 transition-colors duration-200"
                        title="Edit comment"
                      >
                        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
                        </svg>
                      </.link>

                      <.link
                        href={~p"/topics/#{@topic.id}/comments/#{comment.id}"}
                        method="delete"
                        data-confirm="Are you sure you want to delete this comment?"
                        class="text-gray-400 hover:text-red-600 transition-colors duration-200"
                        title="Delete comment"
                      >
                        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                        </svg>
                      </.link>
                    </div>
                  <% end %>
                </div>

                <div class="prose prose-sm max-w-none prose-gray">
                  <p class="text-gray-700 leading-relaxed whitespace-pre-wrap"><%= comment.body %></p>
                </div>
              </div>
            </div>
          </div>
        <% else %>
          <div class="p-12 text-center">
            <svg class="w-12 h-12 mx-auto text-gray-400 mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1" d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z" />
            </svg>
            <p class="text-gray-500 text-lg mb-2">No comments yet</p>
            <p class="text-gray-400">Be the first to share your thoughts!</p>
          </div>
        <% end %>
      </div>

      <!-- Typing Indicators -->
      <%= if length(@typing_users) > 0 do %>
        <div class="px-6 py-2 bg-gray-50 border-t border-gray-200">
          <div class="flex items-center space-x-2 text-sm text-gray-600">
            <div class="flex space-x-1">
              <div class="w-2 h-2 bg-indigo-500 rounded-full animate-bounce"></div>
              <div class="w-2 h-2 bg-indigo-500 rounded-full animate-bounce" style="animation-delay: 0.1s"></div>
              <div class="w-2 h-2 bg-indigo-500 rounded-full animate-bounce" style="animation-delay: 0.2s"></div>
            </div>
            <span>
              <%= case length(@typing_users) do %>
                <% 1 -> %>
                  <%= Enum.at(@typing_users, 0) %> is typing...
                <% 2 -> %>
                  <%= Enum.join(@typing_users, " and ") %> are typing...
                <% count when count > 2 -> %>
                  <%= Enum.at(@typing_users, 0) %> and <%= count - 1 %> others are typing...
              <% end %>
            </span>
          </div>
        </div>
      <% end %>

      <!-- Comment Form -->
      <%= if @current_user do %>
        <div class="border-t border-gray-200 p-6 bg-gray-50">
          <div class="flex items-start space-x-4">
            <!-- User Avatar -->
            <div class="w-10 h-10 rounded-full bg-gradient-to-br from-indigo-500 to-purple-600 flex items-center justify-center shadow-sm flex-shrink-0">
              <span class="text-sm font-bold text-white">
                <%= String.first(Discuss.Accounts.User.username(@current_user)) |> String.upcase() %>
              </span>
            </div>

            <!-- Comment Form -->
            <div class="flex-1">
              <.form
                for={@form}
                phx-submit="submit_comment"
                phx-hook="CommentForm"
                class="space-y-3"
              >
                <.input
                  field={@form[:body]}
                  type="textarea"
                  placeholder="Share your thoughts..."
                  rows="3"
                  class="w-full border-gray-300 rounded-lg shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
                  phx-keydown="typing"
                  phx-blur="stop_typing"
                  required
                />

                <div class="flex justify-end">
                  <.button
                    type="submit"
                    class="px-6 py-2 bg-indigo-600 hover:bg-indigo-700 text-white font-medium rounded-lg transition-colors duration-200"
                  >
                    Post Comment
                  </.button>
                </div>
              </.form>
            </div>
          </div>
        </div>
      <% else %>
        <div class="border-t border-gray-200 p-6 bg-gray-50 text-center">
          <p class="text-gray-600 mb-4">Join the conversation!</p>
          <div class="space-x-3">
            <.link
              href={~p"/users/log_in"}
              class="inline-flex items-center px-4 py-2 bg-indigo-600 text-white font-medium rounded-lg hover:bg-indigo-700 transition-colors duration-200"
            >
              Sign In
            </.link>
            <.link
              href={~p"/users/register"}
              class="inline-flex items-center px-4 py-2 border border-gray-300 text-gray-700 font-medium rounded-lg hover:bg-gray-50 transition-colors duration-200"
            >
              Register
            </.link>
          </div>
        </div>
      <% end %>

      <!-- Load More Button -->
      <%= if @comments_pagination.has_next do %>
        <div class="border-t border-gray-200 p-4 bg-white text-center">
          <.button
            phx-click="load_more"
            class="px-6 py-2 bg-gray-600 hover:bg-gray-700 text-white font-medium rounded-lg transition-colors duration-200"
          >
            Load More Comments
          </.button>
        </div>
      <% end %>
    </div>
    """
  end
end
