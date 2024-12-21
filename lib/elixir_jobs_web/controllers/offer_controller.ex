defmodule ElixirJobsWeb.OfferController do
  use ElixirJobsWeb, :controller

  alias ElixirJobs.Core
  alias ElixirJobs.Core.Schemas.Offer

  @type_filters Enum.map(Core.get_job_types(), &to_string/1)
  @place_filters Enum.map(Core.get_job_places(), &to_string/1)

  plug :scrub_params, "offer" when action in [:create, :preview]

  @spec index(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def index(%Plug.Conn{} = conn, params) do
    page_number = get_page_number(params)

    page = Core.list_offers(published: true, page: page_number)

    conn
    |> assign(:show_hero, true)
    |> assign(:offers, page.entries)
    |> assign(:page_number, page.page_number)
    |> assign(:total_pages, page.total_pages)
    |> render("index.html")
  end

  @spec index_filtered(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def index_filtered(%Plug.Conn{} = conn, %{"filter" => filter}) when filter in @type_filters do
    updated_params = %{"filters" => %{"job_type" => filter}}

    updated_conn =
      conn
      |> Map.put(:query_params, updated_params)
      |> Map.put(:params, updated_params)

    search(updated_conn, updated_params)
  end

  @spec index_filtered(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def index_filtered(%Plug.Conn{} = conn, %{"filter" => filter}) when filter in @place_filters do
    updated_params = %{"filters" => %{"job_place" => filter}}

    updated_conn =
      conn
      |> Map.put(:query_params, updated_params)
      |> Map.put(:params, updated_params)

    search(updated_conn, updated_params)
  end

  @spec index_filtered(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def index_filtered(%Plug.Conn{} = conn, _params) do
    raise Phoenix.Router.NoRouteError, conn: conn, router: ElixirJobsWeb.Router
  end

  @spec search(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def search(%Plug.Conn{} = conn, params) do
    page_number = get_page_number(params)

    opts =
      params
      |> Map.get("filters", %{})
      |> Enum.reduce([published: true], fn
        {"job_place", value}, acc ->
          Keyword.put(acc, :job_place, value)

        {"job_type", value}, acc ->
          Keyword.put(acc, :job_type, value)

        {"text", value}, acc when is_binary(value) ->
          Keyword.put(acc, :search_text, String.trim(value))

        _, acc ->
          acc
      end)
      |> Enum.reject(fn {_, v} -> is_nil(v) or v == "" end)
      |> Keyword.put(:page, page_number)

    page = Core.list_offers(opts)

    conn
    |> assign(:show_hero, true)
    |> assign(:offers, page.entries)
    |> assign(:page_number, page.page_number)
    |> assign(:total_pages, page.total_pages)
    |> render("index.html")
  end

  @spec new(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def new(%Plug.Conn{} = conn, _params) do
    changeset = Core.change_offer(%Offer{})

    render(conn, "new.html", changeset: changeset)
  end

  @spec create(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def create(%Plug.Conn{} = conn, %{"offer" => offer_params}) do
    # Line breaks sent by the browser are received as two bytes, while Ecto
    # changeset counts only one, causing issues with limited fields.
    # This snippet solves that.
    offer_corrected =
      Enum.reduce(offer_params, %{}, fn el, acc ->
        case el do
          {k, v} when is_binary(v) -> Map.put(acc, k, String.replace(v, "\r\n", "\n"))
          {k, v} -> Map.put(acc, k, v)
          _ -> acc
        end
      end)

    case Core.create_offer(offer_corrected) do
      {:ok, offer} ->
        ElixirJobsWeb.Email.notification_offer_created_html(offer)

        flash_msg =
          gettext("<b>Job offer successfully sent!</b> We will review and publish it soon")

        conn
        |> put_flash(:info, flash_msg)
        |> redirect(to: offer_path(conn, :new))

      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  @spec preview(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def preview(%Plug.Conn{} = conn, %{"offer" => offer_params}) do
    job_place =
      offer_params
      |> Map.get("job_place")
      |> Kernel.||("unknown")
      |> String.to_existing_atom()

    job_type =
      offer_params
      |> Map.get("job_type")
      |> Kernel.||("unknown")
      |> String.to_existing_atom()

    offer_preview = %Offer{
      title: Map.get(offer_params, "title") || gettext("Title of your offer"),
      company: Map.get(offer_params, "company") || gettext("Company"),
      summary: Map.get(offer_params, "summary") || gettext("Summary of your offer"),
      location: Map.get(offer_params, "location") || gettext("Location"),
      url: Map.get(offer_params, "url") || "https://example.com",
      slug: "",
      job_place: job_place,
      job_type: job_type,
      published_at: DateTime.utc_now()
    }

    conn
    |> put_layout(false)
    |> render("preview.html", offer: offer_preview)
  end

  @spec show(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def show(%Plug.Conn{} = conn, %{"slug" => slug}) do
    offer =
      if user_logged_in?(conn) do
        Core.get_offer_by_slug!(slug)
      else
        Core.get_offer_by_slug!(slug, published: true)
      end

    render(conn, "show.html", offer: offer)
  end

  @spec rss(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def rss(%Plug.Conn{} = conn, _params) do
    offers = Core.list_offers(published: true, page: 1)
    render(conn, "rss.xml", offers: offers.entries)
  end

  @spec get_page_number(map()) :: non_neg_integer()
  defp get_page_number(params) do
    with {:ok, page_no} when is_binary(page_no) <- Map.fetch(params, "page"),
         {value, _} <- Integer.parse(page_no) do
      value
    else
      _ -> 1
    end
  end
end
