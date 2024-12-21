defmodule ElixirJobs.Accounts.Queries.Admin do
  @moduledoc """
  Module to build queries related to the Admin schema
  """

  import Ecto.Query, warn: false

  def by_id(query, id) do
    from a in query, where: a.id == ^id
  end

  @spec by_email(Ecto.Query.t(), String.t()) :: Ecto.Query.t()
  def by_email(query, email) do
    from a in query, where: a.email == ^email
  end

  @spec only_admin_emails(Ecto.Query.t()) :: Ecto.Query.t()
  def only_admin_emails(query) do
    from admin in query, select: {admin.name, admin.email}
  end
end
