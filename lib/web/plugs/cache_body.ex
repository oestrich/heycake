defmodule Web.Plugs.CacheBody do
  @moduledoc """
  Read the full body and cache in an assigns
  """

  def read_body(conn, opts) do
    {:ok, body, conn} = Plug.Conn.read_body(conn, opts)
    conn = update_in(conn.assigns[:raw_body], fn _existing -> body end)
    {:ok, body, conn}
  end
end
