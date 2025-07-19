defmodule DiscussWeb.UserSettingsLive do
  use DiscussWeb, :live_view

  alias Discuss.Accounts

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gradient-to-br from-gray-50 via-blue-50 to-indigo-50 py-8">
      <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
        <!-- Header Section -->
        <div class="bg-white rounded-2xl shadow-lg overflow-hidden mb-8">
          <div class="bg-gradient-to-r from-indigo-600 via-purple-600 to-blue-600 px-8 py-12">
            <div class="flex items-center space-x-6">
              <!-- Large Avatar -->
              <div class="w-24 h-24 rounded-full bg-white/20 backdrop-blur-sm flex items-center justify-center border-4 border-white/30">
                <span class="text-3xl font-bold text-white">
                  <%= String.first(Discuss.Accounts.User.username(@current_user)) |> String.upcase() %>
                </span>
              </div>

              <div class="flex-1">
                <h1 class="text-3xl font-bold text-white mb-2">Account Settings</h1>
                <p class="text-lg text-white/80 mb-1">Welcome, <%= Discuss.Accounts.User.username(@current_user) %>!</p>
                <p class="text-sm text-white/60"><%= @current_user.email %></p>
              </div>
            </div>
          </div>
        </div>

        <!-- Settings Cards -->
        <div class="grid grid-cols-1 lg:grid-cols-2 gap-8">
          <!-- Email Settings Card -->
          <div class="bg-white rounded-2xl shadow-lg overflow-hidden">
            <div class="bg-gradient-to-r from-blue-500 to-cyan-500 px-6 py-4">
              <div class="flex items-center space-x-3">
                <div class="w-10 h-10 bg-white/20 rounded-lg flex items-center justify-center">
                  <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 12a4 4 0 10-8 0 4 4 0 008 0zm0 0v1.5a2.5 2.5 0 005 0V12a9 9 0 10-9 9m4.5-1.206a8.959 8.959 0 01-4.5 1.207" />
                  </svg>
                </div>
                <div>
                  <h2 class="text-xl font-semibold text-white">Email Address</h2>
                  <p class="text-white/80 text-sm">Update your email address</p>
                </div>
              </div>
            </div>

            <div class="p-6">
              <.simple_form
                for={@email_form}
                id="email_form"
                phx-submit="update_email"
                phx-change="validate_email"
                class="space-y-4"
              >
                <.input
                  field={@email_form[:email]}
                  type="email"
                  label="New Email Address"
                  required
                  class="rounded-lg border-gray-300 focus:border-blue-500 focus:ring-blue-500"
                />
                <.input
                  field={@email_form[:current_password]}
                  name="current_password"
                  id="current_password_for_email"
                  type="password"
                  label="Current Password"
                  value={@email_form_current_password}
                  required
                  class="rounded-lg border-gray-300 focus:border-blue-500 focus:ring-blue-500"
                />
                <:actions>
                  <.button
                    phx-disable-with="Updating..."
                    class="w-full bg-gradient-to-r from-blue-500 to-cyan-500 hover:from-blue-600 hover:to-cyan-600 text-white font-semibold py-3 px-6 rounded-lg transition-all duration-200 shadow-lg hover:shadow-xl"
                  >
                    Update Email Address
                  </.button>
                </:actions>
              </.simple_form>
            </div>
          </div>

          <!-- Password Settings Card -->
          <div class="bg-white rounded-2xl shadow-lg overflow-hidden">
            <div class="bg-gradient-to-r from-purple-500 to-pink-500 px-6 py-4">
              <div class="flex items-center space-x-3">
                <div class="w-10 h-10 bg-white/20 rounded-lg flex items-center justify-center">
                  <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" />
                  </svg>
                </div>
                <div>
                  <h2 class="text-xl font-semibold text-white">Password Security</h2>
                  <p class="text-white/80 text-sm">Change your account password</p>
                </div>
              </div>
            </div>

            <div class="p-6">
              <.simple_form
                for={@password_form}
                id="password_form"
                action={~p"/users/log_in?_action=password_updated"}
                method="post"
                phx-change="validate_password"
                phx-submit="update_password"
                phx-trigger-action={@trigger_submit}
                class="space-y-4"
              >
                <input
                  name={@password_form[:email].name}
                  type="hidden"
                  id="hidden_user_email"
                  value={@current_email}
                />
                <.input
                  field={@password_form[:password]}
                  type="password"
                  label="New Password"
                  required
                  class="rounded-lg border-gray-300 focus:border-purple-500 focus:ring-purple-500"
                />
                <.input
                  field={@password_form[:password_confirmation]}
                  type="password"
                  label="Confirm New Password"
                  class="rounded-lg border-gray-300 focus:border-purple-500 focus:ring-purple-500"
                />
                <.input
                  field={@password_form[:current_password]}
                  name="current_password"
                  type="password"
                  label="Current Password"
                  id="current_password_for_password"
                  value={@current_password}
                  required
                  class="rounded-lg border-gray-300 focus:border-purple-500 focus:ring-purple-500"
                />
                <:actions>
                  <.button
                    phx-disable-with="Updating..."
                    class="w-full bg-gradient-to-r from-purple-500 to-pink-500 hover:from-purple-600 hover:to-pink-600 text-white font-semibold py-3 px-6 rounded-lg transition-all duration-200 shadow-lg hover:shadow-xl"
                  >
                    Update Password
                  </.button>
                </:actions>
              </.simple_form>
            </div>
          </div>
        </div>

        <!-- Account Info Card -->
        <div class="mt-8 bg-white rounded-2xl shadow-lg overflow-hidden">
          <div class="bg-gradient-to-r from-green-500 to-emerald-500 px-6 py-4">
            <div class="flex items-center space-x-3">
              <div class="w-10 h-10 bg-white/20 rounded-lg flex items-center justify-center">
                <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
              </div>
              <div>
                <h2 class="text-xl font-semibold text-white">Account Information</h2>
                <p class="text-white/80 text-sm">Your account details and statistics</p>
              </div>
            </div>
          </div>

          <div class="p-6">
            <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
              <div class="text-center p-4 bg-gray-50 rounded-xl">
                <div class="text-2xl font-bold text-gray-900 mb-1"><%= Discuss.Accounts.User.username(@current_user) %></div>
                <div class="text-sm text-gray-500">Username</div>
              </div>

              <div class="text-center p-4 bg-gray-50 rounded-xl">
                <div class="text-2xl font-bold text-gray-900 mb-1">
                  <%= if @current_user.confirmed_at, do: "Verified", else: "Pending" %>
                </div>
                <div class="text-sm text-gray-500">Email Status</div>
              </div>

              <div class="text-center p-4 bg-gray-50 rounded-xl">
                <div class="text-2xl font-bold text-gray-900 mb-1">
                  <%= Calendar.strftime(@current_user.inserted_at, "%b %Y") %>
                </div>
                <div class="text-sm text-gray-500">Member Since</div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def mount(%{"token" => token}, _session, socket) do
    socket =
      case Accounts.update_user_email(socket.assigns.current_user, token) do
        :ok ->
          put_flash(socket, :info, "Email changed successfully.")

        :error ->
          put_flash(socket, :error, "Email change link is invalid or it has expired.")
      end

    {:ok, push_navigate(socket, to: ~p"/users/settings")}
  end

  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    email_changeset = Accounts.change_user_email(user)
    password_changeset = Accounts.change_user_password(user)

    socket =
      socket
      |> assign(:current_password, nil)
      |> assign(:email_form_current_password, nil)
      |> assign(:current_email, user.email)
      |> assign(:email_form, to_form(email_changeset))
      |> assign(:password_form, to_form(password_changeset))
      |> assign(:trigger_submit, false)

    {:ok, socket}
  end

  def handle_event("validate_email", params, socket) do
    %{"current_password" => password, "user" => user_params} = params

    email_form =
      socket.assigns.current_user
      |> Accounts.change_user_email(user_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, email_form: email_form, email_form_current_password: password)}
  end

  def handle_event("update_email", params, socket) do
    %{"current_password" => password, "user" => user_params} = params
    user = socket.assigns.current_user

    case Accounts.apply_user_email(user, password, user_params) do
      {:ok, applied_user} ->
        Accounts.deliver_user_update_email_instructions(
          applied_user,
          user.email,
          &url(~p"/users/settings/confirm_email/#{&1}")
        )

        info = "A link to confirm your email change has been sent to the new address."
        {:noreply, socket |> put_flash(:info, info) |> assign(email_form_current_password: nil)}

      {:error, changeset} ->
        {:noreply, assign(socket, :email_form, to_form(Map.put(changeset, :action, :insert)))}
    end
  end

  def handle_event("validate_password", params, socket) do
    %{"current_password" => password, "user" => user_params} = params

    password_form =
      socket.assigns.current_user
      |> Accounts.change_user_password(user_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, password_form: password_form, current_password: password)}
  end

  def handle_event("update_password", params, socket) do
    %{"current_password" => password, "user" => user_params} = params
    user = socket.assigns.current_user

    case Accounts.update_user_password(user, password, user_params) do
      {:ok, user} ->
        password_form =
          user
          |> Accounts.change_user_password(user_params)
          |> to_form()

        {:noreply, assign(socket, trigger_submit: true, password_form: password_form)}

      {:error, changeset} ->
        {:noreply, assign(socket, password_form: to_form(changeset))}
    end
  end
end
