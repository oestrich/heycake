defmodule Web.PageController do
  use Web, :controller

  alias Web.Router.Helpers, as: Routes

  def index(conn, _params) do
    conn
    |> assign(:open_graph_title, "heycake")
    |> assign(:open_graph_description, "Let your team eat 🍰")
    |> assign(:open_graph_url, Routes.page_url(conn, :index))
    |> render("index.html")
  end

  def health(conn, _params) do
    send_resp(conn, 200, "OK\n")
  end
end
