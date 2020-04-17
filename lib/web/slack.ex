defmodule Web.Slack do
  @moduledoc """
  Deal with Slack webhooks and requests
  """

  alias HeyCake.Config

  @doc """
  Validate a webhook from slack was sent from slack
  """
  def validate_request(signature, timestamp, raw_body) do
    with :ok <- check_timestamp(timestamp),
         :ok <- check_signature(signature, timestamp, raw_body) do
      :valid
    end
  end

  defp check_timestamp(timestamp, now \\ Timex.now()) do
    {timestamp, _rest} = Integer.parse(timestamp)
    timestamp = Timex.from_unix(timestamp)

    case abs(Timex.diff(now, timestamp, :second)) < 900 do
      true ->
        :ok

      false ->
        {:error, :invalid_timestamp}
    end
  end

  defp check_signature(actual_signature, timestamp, body) do
    signing_key = Config.slack_signing_id()

    plaintext = "v0:" <> to_string(timestamp) <> ":" <> body

    hexdigest = Base.encode16(:crypto.hmac(:sha256, signing_key, plaintext), case: :lower)
    expected_signature = "v0=" <> hexdigest

    case actual_signature == expected_signature do
      true ->
        :ok

      false ->
        {:error, :invalid_signature}
    end
  end
end
