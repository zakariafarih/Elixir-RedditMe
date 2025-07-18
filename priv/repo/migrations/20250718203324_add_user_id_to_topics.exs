defmodule Discuss.Repo.Migrations.AddUserIdToTopics do
  use Ecto.Migration

  def change do
    alter table(:topics) do
      # Adding a user_id column to the topics table
      # This column will reference the users table
      # and will be used to associate topics with their respective users.
      add :user_id, references(:users, on_delete: :nilify_all)
      # nilify_all is a custom option to handle deletion of users and their topics
    end

    # Creating an index on the user_id column for faster lookups
    # This will improve performance when querying topics by user.
    create index(:topics, [:user_id])
  end
end
