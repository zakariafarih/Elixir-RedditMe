defmodule Discuss.Repo.Migrations.CreateVotes do
  use Ecto.Migration

  def change do
    create table(:votes) do
      add :vote_type, :string, null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :topic_id, references(:topics, on_delete: :delete_all), null: false

      timestamps()
    end

    create unique_index(:votes, [:user_id, :topic_id])
    create index(:votes, [:topic_id])
    create index(:votes, [:user_id])
  end
end
