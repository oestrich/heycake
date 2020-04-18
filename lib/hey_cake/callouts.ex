defmodule HeyCake.Callouts do
  @moduledoc """
  Context for callouts
  """

  alias HeyCake.Callouts.Callout
  alias HeyCake.Repo

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
