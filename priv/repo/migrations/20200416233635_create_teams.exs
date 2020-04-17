defmodule HeyCake.Repo.Migrations.CreateTeams do
  use Ecto.Migration

  def change do
    create table(:teams) do
      add(:user_id, references(:users), null: false)

      add(:slack_id, :string, null: false)
      add(:token, :string, null: false)

      timestamps()
    end

    create index(:teams, :slack_id, unique: true)
  end
end
