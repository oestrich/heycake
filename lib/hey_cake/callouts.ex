defmodule HeyCake.Callouts do
  @moduledoc """
  Context for callouts
  """

  import Ecto.Query

  alias HeyCake.Callouts.Callout
  alias HeyCake.Repo

  @doc """
  Get callouts for a user's teams
  """
  def for_user_teams(user) do
    Callout
    |> join(:inner, [c], t in assoc(c, :team))
    |> where([c, t], t.user_id == ^user.id)
    |> order_by([c, t], desc: c.inserted_at)
    |> preload([:channel, :sending_user, :receiving_user])
    |> Repo.all()
  end

  @doc """
  Record callouts on a team
  """
  def record(team, params) do
    team
    |> Ecto.build_assoc(:callouts)
    |> Callout.create_changeset(params)
    |> Repo.insert()
  end
end
