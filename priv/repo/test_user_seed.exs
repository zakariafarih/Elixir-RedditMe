# File: priv/repo/test_user_seed.exs
# Run with: mix run priv/repo/test_user_seed.exs

alias Discuss.Accounts
alias Discuss.Content

# Create a test user
user_attrs = %{
  email: "test@example.com",
  password: "password123456"
}

case Accounts.register_user(user_attrs) do
  {:ok, user} ->
    IO.puts("✓ Created test user: #{user.email}")

    # Create some topics for this user
    topics_data = [
      %{
        title: "My First Topic",
        body: "This is my first topic created as a logged-in user. I can edit and delete this topic."
      },
      %{
        title: "Another Topic by Test User",
        body: "This is another topic to test the ownership features. Only I should be able to edit/delete this."
      }
    ]

    Enum.each(topics_data, fn topic_attrs ->
      case Content.create_topic(topic_attrs, user) do
        {:ok, topic} ->
          IO.puts("✓ Created topic: #{topic.title}")
        {:error, changeset} ->
          IO.puts("✗ Failed to create topic: #{topic_attrs.title}")
          IO.inspect(changeset.errors)
      end
    end)

    IO.puts("\nTest user created successfully!")
    IO.puts("Email: test@example.com")
    IO.puts("Password: password123456")
    IO.puts("\nYou can now:")
    IO.puts("1. Visit http://localhost:4000")
    IO.puts("2. Click 'Sign In'")
    IO.puts("3. Use the credentials above to log in")
    IO.puts("4. Test creating, editing, and deleting topics")

  {:error, changeset} ->
    IO.puts("✗ Failed to create test user")
    IO.inspect(changeset.errors)
end
