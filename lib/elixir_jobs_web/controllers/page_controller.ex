defmodule ElixirJobsWeb.PageController do
  use ElixirJobsWeb, :controller

  @spec about(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def about(%Plug.Conn{} = conn, _params) do
    render(conn, "about.html")
  end

  @spec sponsors(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def sponsors(%Plug.Conn{} = conn, _params) do
    render(conn, "sponsors.html")
  end
end
