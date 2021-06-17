defmodule HeyCake.Repo.Migrations.CreateSlackUsers do
  use Ecto.Migration

  def change do
    create table(:slack_users) do
      add(:team_id, references(:teams), null: false)
      add(:slack_id, :string, null: false)
      add(:name, :string, null: false)

      timestamps()
    end
  end
end
