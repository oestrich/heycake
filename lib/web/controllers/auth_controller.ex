defmodule Web.AuthController do
  use Web, :controller

  alias HeyCake.Teams

  plug Ueberauth

  def callback(conn = %{assigns: %{ueberauth_auth: auth}}, %{"provider" => "slack"}) do
    %{current_user: user} = conn.assigns

    team_id = auth.credentials.other.team_id
    token = auth.extra.raw_info.token.other_params["bot"]["bot_access_token"]

    case Teams.register_team(user, team_id, token) do
      {:ok, _team} ->
        conn
        |> put_flash(:info, "Authenticated!")
        |> redirect(to: Routes.page_path(conn, :index))

      {:error, _changeset} ->
        conn
        |> put_flash(:error, "There was an error authenticating")
        |> redirect(to: Routes.page_path(conn, :index))
    end
  end
end
