defmodule ElixirJobsWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common datastructures and query the data layer.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate

  alias Ecto.Adapters.SQL.Sandbox, as: SQLSandbox

  using do
    quote do
      # The default endpoint for testing
      @endpoint ElixirJobsWeb.Endpoint

      use ElixirJobsWeb, :verified_routes
      # Import conveniences for testing with connections
      import Plug.Conn
      import Phoenix.ConnTest
      import ElixirJobsWeb.Router.Helpers

      import ElixirJobs.Factory
    end
  end

  setup tags do
    :ok = SQLSandbox.checkout(ElixirJobs.Repo)

    if !tags[:async] do
      SQLSandbox.mode(ElixirJobs.Repo, {:shared, self()})
    end

    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end
end
