defmodule ElixirJobsWeb.AuthController do
  use ElixirJobsWeb, :controller

  alias ElixirJobs.Accounts
  alias ElixirJobsWeb.Guardian

  plug :scrub_params, "auth" when action in [:create]

  @spec new(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def new(%Plug.Conn{} = conn, _params) do
    render(conn, "new.html")
  end

  @spec create(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def create(%Plug.Conn{} = conn, %{"auth" => auth_params}) do
    with {:ok, email} <- Map.fetch(auth_params, "email"),
         {:ok, password} <- Map.fetch(auth_params, "password"),
         {:ok, admin} <- Accounts.authenticate_admin(email, password) do
      conn
      |> Guardian.Plug.sign_in(admin)
      |> put_flash(:info, gettext("Welcome %{user_name}!", user_name: admin.name))
      |> redirect(to: offer_path(conn, :index))
    else
      _ ->
        conn
        |> put_flash(:error, "Invalid credentials!")
        |> render("new.html")
    end
  end

  @spec delete(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def delete(%Plug.Conn{} = conn, _params) do
    conn
    |> Guardian.Plug.sign_out()
    |> put_flash(:info, gettext("Successfully logged out! See you!"))
    |> redirect(to: auth_path(conn, :new))
  end

  def auth_error(%Plug.Conn{} = conn, {_type, _reason}, _opts) do
    conn
    |> Guardian.Plug.sign_out()
    |> put_flash(:error, gettext("Authentication required"))
    |> redirect(to: auth_path(conn, :new))
  end
end
