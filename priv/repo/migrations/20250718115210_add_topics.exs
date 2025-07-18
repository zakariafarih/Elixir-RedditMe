defmodule Discuss.Repo.Migrations.AddTopics do
  use Ecto.Migration

  def change do
    create table(:topics) do
      add :title, :string, null: false
      add :body,  :text,   null: false

      timestamps()
    end
  end
end
