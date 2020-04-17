defmodule Web.WebhookController do
  use Web, :controller

  alias HeyCake.Slack

  plug Web.Plugs.VerifySlack when action in [:slack]

  def slack(conn, %{"challenge" => challenge}) do
    send_resp(conn, 200, challenge)
  end

  def slack(conn, params) do
    Slack.process_event(params)

    send_resp(conn, 204, "")
  end
end
