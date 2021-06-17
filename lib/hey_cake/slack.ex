defmodule HeyCake.Slack.SlackChannel do
  @moduledoc """
  Cached slack channel information
  """

  use Ecto.Schema

  alias HeyCake.Teams.Team

  schema "slack_channels" do
    field(:slack_id, :string)
    field(:name, :string)

    belongs_to(:team, Team)

    timestamps()
  end
end

defmodule HeyCake.Slack.SlackUser do
  @moduledoc """
  Cached slack user information
  """

  use Ecto.Schema

  alias HeyCake.Teams.Team

  schema "slack_users" do
    field(:slack_id, :string)
    field(:name, :string)

    belongs_to(:team, Team)

    timestamps()
  end
end

defmodule HeyCake.Slack do
  @moduledoc """
  Handler for Slack events
  """

  alias HeyCake.Slack.SlackChannel
  alias HeyCake.Slack.SlackUser
  alias HeyCake.Slack.Worker
  alias HeyCake.Repo

  @doc """
  Process an event from Slack
  """
  def process_event(params)

  def process_event(%{"command" => "/heycake"}), do: :ok

  def process_event(params = %{"event" => %{"type" => "message"}}) do
    params
    |> Worker.new()
    |> Oban.insert()
  end

  def process_event(_params), do: :ok

  def cache_channel(channel) do
    case Repo.get_by(SlackChannel, slack_id: channel.id) do
      nil ->
        %SlackChannel{}
        |> Ecto.Changeset.change()
        |> Ecto.Changeset.put_change(:slack_id, channel.id)
        |> Ecto.Changeset.put_change(:name, channel.name)
        |> Ecto.Changeset.put_change(:team_id, channel.team_id)
        |> Repo.insert()

      slack_channel ->
        slack_channel
        |> Repo.preload([:team])
        |> Ecto.Changeset.change()
        |> Ecto.Changeset.put_change(:slack_id, channel.id)
        |> Ecto.Changeset.put_change(:name, channel.name)
        |> Ecto.Changeset.put_change(:team_id, channel.team_id)
        |> Repo.update()
    end
  end

  def cache_user(user) do
    case Repo.get_by(SlackUser, slack_id: user.id) do
      nil ->
        %SlackUser{}
        |> Ecto.Changeset.change()
        |> Ecto.Changeset.put_change(:slack_id, user.id)
        |> Ecto.Changeset.put_change(:name, user.name)
        |> Ecto.Changeset.put_change(:team_id, user.team_id)
        |> Repo.insert()

      slack_user ->
        slack_user
        |> Ecto.Changeset.change()
        |> Ecto.Changeset.put_change(:slack_id, user.id)
        |> Ecto.Changeset.put_change(:name, user.name)
        |> Ecto.Changeset.put_change(:team_id, user.team_id)
        |> Repo.update()
    end
  end
end

defmodule HeyCake.Slack.Worker do
  @moduledoc false

  use Oban.Worker, queue: :slack

  alias HeyCake.Slack.Events.Message

  @impl true
  def perform(%Oban.Job{args: event}) do
    Message.process(event["event"])

    {:ok, event}
  end
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
  alias HeyCake.Slack
  alias HeyCake.Slack.Client
  alias HeyCake.Slack.Event
  alias HeyCake.Teams

  @emoji [
    "birthday",
    "bubble_tea",
    "cake",
    "candy",
    "chestnut",
    "chocolate_bar",
    "cookie",
    "croissant",
    "cupcake",
    "custard",
    "doughnut",
    "honey_pot",
    "ice_cream",
    "icecream",
    "lollipop",
    "moon_cake",
    "pie",
    "popcorn",
    "shaved_ice"
  ]

  @impl true
  def process(event) do
    %{"ts" => timestamp} = event

    {:ok, team} = Teams.get(Map.fetch!(event, "team"))

    text_elements = Event.text_elements(Map.fetch!(event, "blocks"))

    case contains_emoji?(text_elements) && contains_users?(text_elements) do
      true ->
        channel_id = Map.fetch!(event, "channel")
        sending_user_id = Map.fetch!(event, "user")
        text = Map.fetch!(event, "text")

        users =
          text_elements
          |> Enum.filter(fn element ->
            element["type"] == "user"
          end)
          |> Enum.map(fn element ->
            element["user_id"]
          end)

        emoji =
          text_elements
          |> Enum.filter(fn element ->
            element["type"] == "emoji"
          end)
          |> Enum.map(fn element ->
            element["name"]
          end)

        Enum.each(users, fn receiving_user_id ->
          {:ok, channel} = Client.channel_info(team, channel_id)
          {:ok, sending_user} = Client.user_info(team, sending_user_id)
          {:ok, receiving_user} = Client.user_info(team, receiving_user_id)

          {:ok, channel} = Slack.cache_channel(channel)
          {:ok, sending_user} = Slack.cache_user(sending_user)
          {:ok, receiving_user} = Slack.cache_user(receiving_user)

          {:ok, _callout} =
            Callouts.record(team, %{
              channel_id: channel.id,
              sending_user_id: sending_user.id,
              receiving_user_id: receiving_user.id,
              text: text,
              emoji: emoji
            })
        end)

        Client.react(team, channel_id, timestamp, "white_check_mark")

      false ->
        :ok
    end
  end

  def contains_emoji?(text_elements) do
    Enum.any?(text_elements, fn element ->
      element["type"] == "emoji" && Enum.member?(@emoji, element["name"])
    end)
  end

  def contains_users?(text_elements) do
    Enum.any?(text_elements, fn element ->
      element["type"] == "user"
    end)
  end
end

defmodule HeyCake.Slack.User do
  @moduledoc false

  defstruct [:id, :name, :team_id]
end

defmodule HeyCake.Slack.Channel do
  @moduledoc false

  defstruct [:id, :name, :team_id]
end

defmodule HeyCake.Slack.Client do
  @moduledoc """
  Slack client
  """

  alias HeyCake.Slack.Channel
  alias HeyCake.Slack.User

  @doc """
  React to a message in a channel, noting that it was seen
  """
  def react(team, channel_id, timestamp, emoji \\ "cake") do
    query =
      URI.encode_query(
        token: team.token,
        channel: channel_id,
        timestamp: timestamp,
        name: emoji
      )

    uri = URI.parse("https://slack.com/api/reactions.add")
    uri = Map.put(uri, :query, query)
    uri = URI.to_string(uri)

    Mojito.post(uri)
  end

  def channel_info(team, channel_id) do
    query =
      URI.encode_query(
        token: team.token,
        channel: channel_id
      )

    uri = URI.parse("https://slack.com/api/conversations.info")
    uri = Map.put(uri, :query, query)
    uri = URI.to_string(uri)

    case Mojito.get(uri) do
      {:ok, %{status_code: 200, body: body}} ->
        {:ok, json} = Jason.decode(body)

        channel = %Channel{
          id: json["channel"]["id"],
          name: json["channel"]["name"],
          team_id: team.id
        }

        {:ok, channel}
    end
  end

  def user_info(team, user_id) do
    query =
      URI.encode_query(
        token: team.token,
        user: user_id
      )

    uri = URI.parse("https://slack.com/api/users.info")
    uri = Map.put(uri, :query, query)
    uri = URI.to_string(uri)

    case Mojito.get(uri) do
      {:ok, %{status_code: 200, body: body}} ->
        {:ok, json} = Jason.decode(body)

        user = %User{
          id: json["user"]["id"],
          name: json["user"]["name"],
          team_id: team.id
        }

        {:ok, user}
    end
  end

  def emoji(team) do
    query =
      URI.encode_query(
        token: team.token
      )

    uri = URI.parse("https://slack.com/api/emoji.list")
    uri = Map.put(uri, :query, query)
    uri = URI.to_string(uri)

    case Mojito.get(uri) do
      {:ok, %{status_code: 200, body: body}} ->
        Jason.decode(body)
    end
  end
end
