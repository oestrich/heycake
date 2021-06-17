defmodule HeyCake.Callouts.Callout do
  @moduledoc """
  User schema
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias HeyCake.Teams.Team
  alias HeyCake.Slack.SlackChannel
  alias HeyCake.Slack.SlackUser

  @type t :: %__MODULE__{}

  schema "callouts" do
    field(:text, :string)
    field(:emoji, {:array, :string})

    belongs_to(:team, Team)
    belongs_to(:channel, SlackChannel)
    belongs_to(:sending_user, SlackUser)
    belongs_to(:receiving_user, SlackUser)

    timestamps()
  end

  def create_changeset(struct, params) do
    struct
    |> cast(params, [:emoji, :text, :channel_id, :sending_user_id, :receiving_user_id])
    |> validate_required([
      :emoji,
      :text,
      :channel_id,
      :sending_user_id,
      :receiving_user_id,
      :team_id
    ])
  end
end
