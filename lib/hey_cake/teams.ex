defmodule HeyCake.Teams do
  @moduledoc """
  Context for teams
  """

  alias HeyCake.Repo
  alias HeyCake.Teams.Team

  @doc """
  Load a team by slack id
  """
  def get(slack_id) when is_binary(slack_id) do
    case Repo.get_by(Team, slack_id: slack_id) do
      nil ->
        {:error, :not_found}

      team ->
        {:ok, team}
    end
  end

  @doc """
  Register a team to a user
  """
  def register_team(user, team_id, token) do
    case Repo.get_by(Team, slack_id: team_id) do
      team when not is_nil(team) ->
        team
        |> Team.update_changeset(%{user_id: user.id, slack_id: team_id, token: token})
        |> Repo.update()

      nil ->
        user
        |> Ecto.build_assoc(:teams)
        |> Team.create_changeset(%{slack_id: team_id, token: token})
        |> Repo.insert()
    end
  end
end
