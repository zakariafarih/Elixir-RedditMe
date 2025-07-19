alias Discuss.{Accounts, Content, Repo}

# Create a test user if not exists
user_attrs = %{
  email: "test@discuss.com",
  password: "password123password",
  confirmed_at: DateTime.utc_now()
}

user = case Accounts.get_user_by_email("test@discuss.com") do
  nil ->
    {:ok, user} = Accounts.register_user(user_attrs)
    user
  existing_user ->
    existing_user
end

# Get the first topic for testing
topic = Content.list_topics() |> List.first()

if topic do
  # Create some test comments
  comment_texts = [
    "This is a great topic! Thanks for sharing.",
    "I have a different perspective on this. What do you think about...",
    "Could you elaborate more on the second point? I find it really interesting.",
    "Great explanation! This really helped me understand the concept better.",
    "I disagree with some points here. Let me explain why..."
  ]

  for comment_text <- comment_texts do
    Content.create_comment(user, topic.id, %{body: comment_text})
  end

  IO.puts("Created #{length(comment_texts)} test comments for topic: #{topic.title}")
else
  IO.puts("No topics found. Please create a topic first.")
end
