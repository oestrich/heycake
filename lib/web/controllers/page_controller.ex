defmodule Web.PageController do
  use Web, :controller

  def index(conn, _params) do
    conn
    |> assign(:open_graph_title, "heycake")
    |> assign(:open_graph_description, "Let your team eat 🍰")
    |> render("index.html")
  end

  def health(conn, _params) do
    send_resp(conn, 200, "OK\n")
  end
end
