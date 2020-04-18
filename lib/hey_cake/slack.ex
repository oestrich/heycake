defmodule HeyCake.Slack do
  @moduledoc """
  Handler for Slack events
  """

  alias HeyCake.Slack.Events.Message

  @doc """
  Process an event from Slack
  """
  def process_event(params)

  def process_event(%{"command" => "/heycake"}), do: :ok

  def process_event(params = %{"event" => %{"type" => "message"}}) do
    Message.process(params["event"])
  end

  def process_event(_params), do: :ok
end

defmodule HeyCake.Slack.Event do
  @moduledoc """
  Behaviour and helper functions for processing events
  """

  @callback process(event :: map()) :: :ok

  @doc """
  Load text elements from a set of blocks
  """
  def text_elements(blocks) do
    blocks
    |> Enum.filter(fn block ->
      block["type"] in ["rich_text"]
    end)
    |> Enum.flat_map(fn block ->
      block["elements"]
    end)
    |> Enum.flat_map(fn element ->
      element["elements"]
    end)
  end
end

defmodule HeyCake.Slack.Events.Message do
  @moduledoc """
  Process a message type event
  """

  @behaviour HeyCake.Slack.Event

  alias HeyCake.Callouts
  alias HeyCake.Slack.Client
  alias HeyCake.Slack.Event
  alias HeyCake.Teams

  @impl true
  def process(event) do
    %{"ts" => timestamp} = event

    {:ok, team} = Teams.get(Map.fetch!(event, "team"))

    text_elements = Event.text_elements(Map.fetch!(event, "blocks"))

    case contains_cake?(text_elements) && contains_users?(text_elements) do
      true ->
        channel = Map.fetch!(event, "channel")
        sending_user_id = Map.fetch!(event, "user")
        text = Map.fetch!(event, "text")

        text_elements
        |> Enum.filter(fn element ->
          element["type"] == "user"
        end)
        |> Enum.map(fn element ->
          element["user_id"]
        end)
        |> Enum.each(fn receiving_user_id ->
          {:ok, _callout} =
            Callouts.record(team, %{
              channel_id: channel,
              sending_user_id: sending_user_id,
              receiving_user_id: receiving_user_id,
              text: text
            })
        end)

        Client.react(team, channel, timestamp, "white_check_mark")

      false ->
        :ok
    end
  end

  def contains_cake?(text_elements) do
    Enum.any?(text_elements, fn element ->
      element["type"] == "emoji" && element["name"] == "cake"
    end)
  end

  def contains_users?(text_elements) do
    Enum.any?(text_elements, fn element ->
      element["type"] == "user"
    end)
  end
end

defmodule HeyCake.Slack.Client do
  @moduledoc """
  Slack client
  """

  @doc """
  React to a message in a channel, noting that it was seen
  """
  def react(team, channel, timestamp, emoji \\ "cake") do
    query =
      URI.encode_query(
        token: team.token,
        channel: channel,
        timestamp: timestamp,
        name: emoji
      )

    uri = URI.parse("https://slack.com/api/reactions.add")
    uri = Map.put(uri, :query, query)
    uri = URI.to_string(uri)

    Mojito.post(uri)
  end
end
