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
    field(:user_id, :string)
    field(:user_ids, {:array, :string})

    belongs_to(:team, Team)

    timestamps()
  end

  def create_changeset(struct, channel_id, user_id, user_ids, text) do
    struct
    |> change(%{})
    |> put_change(:channel_id, channel_id)
    |> put_change(:user_id, user_id)
    |> put_change(:user_ids, user_ids)
    |> put_change(:text, text)
    |> validate_required([:channel_id, :text, :user_id, :user_ids, :team_id])
  end
end
