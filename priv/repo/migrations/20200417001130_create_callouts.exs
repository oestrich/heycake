defmodule HeyCake.Repo.Migrations.CreateCallouts do
  use Ecto.Migration

  def change do
    create table(:callouts) do
      add(:team_id, references(:teams), null: false)
      add(:channel_id, :string, null: false)
      add(:sending_user_id, :string, null: false)
      add(:receiving_user_id, :string, null: false)
      add(:text, :text, null: false)

      timestamps()
    end
  end
end
