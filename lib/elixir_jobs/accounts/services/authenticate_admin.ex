defmodule ElixirJobs.Accounts.Services.AuthenticateAdmin do
  @moduledoc """
  Service to make administration authentication
  """

  alias ElixirJobs.Accounts.Managers.Admin, as: AdminManager
  alias ElixirJobs.Accounts.Schemas.Admin

  @doc """
  Receives email and password and tries to fetch the user from the database and
  authenticate it
  """
  @spec call(String.t(), String.t()) ::
          {:ok, Ecto.Schema.t()} | {:error, :wrong_credentials}
  def call(email, password) do
    admin = AdminManager.get_admin_by_email!(email)

    Admin.check_password(admin, password)
  rescue
    Ecto.NoResultsError -> Admin.dummy_check_password()
  end
end
