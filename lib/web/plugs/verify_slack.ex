defmodule Web.Plugs.VerifySlack do
  @moduledoc """
  Verify a webhook is sent from slack
  """

  import Plug.Conn

  alias Web.Slack

  def init(default), do: default

  def call(conn, _opts) do
    with [timestamp] <- get_req_header(conn, "x-slack-request-timestamp"),
         [signature] <- get_req_header(conn, "x-slack-signature"),
         :valid <- Slack.validate_request(signature, timestamp, conn.assigns[:raw_body]) do
      conn
    else
      _ ->
        conn
        |> send_resp(400, "uh oh")
        |> halt()
    end
  end
end
