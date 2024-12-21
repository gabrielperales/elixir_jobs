defmodule ElixirJobsWeb.Plugs.CurrentUser do
  @moduledoc """
  Plug to store current user (if defined) on the connection.
  """

  import Plug.Conn

  alias ElixirJobs.Accounts.Schemas.Admin
  alias ElixirJobsWeb.Guardian.Plug, as: GuardianPlug

  def init(_), do: []

  def call(%Plug.Conn{} = conn, _) do
    case GuardianPlug.current_resource(conn) do
      %Admin{} = user -> assign(conn, :current_user, user)
      _ -> conn
    end
  end

  @spec current_user(Plug.Conn.t()) :: Admin.t() | nil
  def current_user(%Plug.Conn{} = conn) do
    Map.get(conn.assigns, :current_user)
  end

  @spec user_logged_in?(Plug.Conn.t()) :: boolean()
  def user_logged_in?(%Plug.Conn{} = conn), do: !is_nil(Map.get(conn.assigns, :current_user))
end
