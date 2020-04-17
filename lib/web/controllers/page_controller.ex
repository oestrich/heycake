defmodule Web.PageController do
  use Web, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def health(conn, _params) do
    send_resp(conn, 200, "OK\n")
  end
end
