defmodule HeyCake.Callouts do
  @moduledoc """
  Context for callouts
  """

  alias HeyCake.Callouts.Callout
  alias HeyCake.Repo

  @doc """
  Record callouts on a team
  """
  def record(team, channel_id, user_id, user_ids, text) do
    team
    |> Ecto.build_assoc(:callouts)
    |> Callout.create_changeset(channel_id, user_id, user_ids, text)
    |> Repo.insert()
  end
end
