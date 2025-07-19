import Ecto.Query
alias Discuss.Repo
alias Discuss.Accounts.User
alias Discuss.Content.Topic

# Create or find the dev user
dev_user = case Repo.get_by(User, email: "dev@discuss.com") do
  nil ->
    # Create dev user
    {:ok, user} = Discuss.Accounts.register_user(%{
      email: "dev@discuss.com",
      password: "devpassword123!"
    })

    # Confirm the user automatically
    Repo.update_all(
      from(u in User, where: u.id == ^user.id),
      set: [confirmed_at: DateTime.utc_now()]
    )

    IO.puts("✅ Created dev user: dev@discuss.com")
    user

  user ->
    IO.puts("ℹ️  Dev user already exists: dev@discuss.com")
    user
end

# Get all topics without a user_id (null values)
topics_without_user = Repo.all(from t in Topic, where: is_nil(t.user_id))

if Enum.empty?(topics_without_user) do
  IO.puts("ℹ️  No topics found without a user assigned.")
else
  # Assign all topics without user_id to the dev user
  {count, _} = Repo.update_all(
    from(t in Topic, where: is_nil(t.user_id)),
    set: [user_id: dev_user.id, updated_at: DateTime.utc_now()]
  )

  IO.puts("✅ Assigned #{count} topics to dev user (dev@discuss.com)")
end

# Show final counts
total_topics = Repo.aggregate(Topic, :count, :id)
dev_user_topics = Repo.aggregate(from(t in Topic, where: t.user_id == ^dev_user.id), :count, :id)

IO.puts("\n📊 Summary:")
IO.puts("   Total topics: #{total_topics}")
IO.puts("   Topics assigned to dev@discuss.com: #{dev_user_topics}")
