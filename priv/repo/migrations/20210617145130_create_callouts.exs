defmodule HeyCake.Repo.Migrations.CreateCallouts do
  use Ecto.Migration

  def change do
    create table(:callouts) do
      add(:team_id, references(:teams), null: false)
      add(:channel_id, references(:slack_channels), null: false)
      add(:sending_user_id, references(:slack_users), null: false)
      add(:receiving_user_id, references(:slack_users), null: false)
      add(:text, :text, null: false)
      add(:emoji, {:array, :string}, null: false)

      timestamps()
    end
  end
end
