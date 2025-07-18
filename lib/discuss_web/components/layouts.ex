defmodule DiscussWeb.Layouts do
  use DiscussWeb, :html

  embed_templates "layouts/*"

  def app(assigns) do
    ~H"""
    <main class="pt-6 pb-12 px-4 sm:px-6 lg:px-8">
      <div class="mx-auto">
        <%= assigns[:inner_content] || render_slot(@inner_block) %>
      </div>
    </main>
    """
  end
end
