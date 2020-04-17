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
end
