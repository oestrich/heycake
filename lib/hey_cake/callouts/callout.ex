defmodule HeyCake.Callouts.Callout do
  @moduledoc """
  User schema
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias HeyCake.Teams.Team

  @type t :: %__MODULE__{}

  schema "callouts" do
    field(:channel_id, :string)
    field(:text, :string)
    field(:sending_user_id, :string)
    field(:receiving_user_id, :string)

    belongs_to(:team, Team)

    timestamps()
  end

  def create_changeset(struct, params) do
    struct
    |> cast(params, [:channel_id, :text, :sending_user_id, :receiving_user_id])
    |> validate_required([:channel_id, :text, :sending_user_id, :receiving_user_id, :team_id])
  end
end
