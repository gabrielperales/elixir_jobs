defmodule ElixirJobsWeb.Admin.OfferController do
  use ElixirJobsWeb, :controller

  alias ElixirJobs.Core
  alias ElixirJobsWeb.Telegram
  alias ElixirJobsWeb.Twitter

  plug :scrub_params, "offer" when action in [:update]

  @spec index_published(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def index_published(%Plug.Conn{} = conn, params) when is_map(params) do
    page_number =
      with {:ok, page_no} when is_binary(page_no) <- Map.fetch(params, "page"),
           {value, _} <- Integer.parse(page_no) do
        value
      else
        _ -> 1
      end

    pages = Core.list_offers(published: true, page: page_number)

    conn
    |> assign(:offers, pages.entries)
    |> assign(:page_number, pages.page_number)
    |> assign(:total_pages, pages.total_pages)
    |> render("index_published.html")
  end

  def index_unpublished(%Plug.Conn{} = conn, params) when is_map(params) do
    page_number =
      with {:ok, page_no} when is_binary(page_no) <- Map.fetch(params, "page"),
           {value, _} <- Integer.parse(page_no) do
        value
      else
        _ -> 1
      end

    pages = Core.list_offers(published: false, page: page_number)

    conn
    |> assign(:offers, pages.entries)
    |> assign(:page_number, pages.page_number)
    |> assign(:total_pages, pages.total_pages)
    |> render("index_unpublished.html")
  end

  @spec publish(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def publish(%Plug.Conn{} = conn, %{"slug" => slug}) when is_binary(slug) do
    slug
    |> Core.get_offer_by_slug!()
    |> Core.publish_offer()
    |> case do
      {:ok, _offer} ->
        conn
        |> put_flash(:info, gettext("<b>Offer published correctly!</b>"))
        |> redirect(to: offer_path(conn, :show, slug))

      {:error, _} ->
        conn
        |> put_flash(:info, gettext("<b>An error occurred while publishing the offer</b>"))
        |> redirect(to: admin_offer_path(conn, :index_unpublished))
    end
  end

  @spec send_twitter(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def send_twitter(%Plug.Conn{} = conn, %{"slug" => slug}) when is_binary(slug) do
    offer = Core.get_offer_by_slug!(slug)

    Twitter.publish(conn, offer)

    conn
    |> put_flash(:info, gettext("<b>Offer correctly sent to Twitter account!</b>"))
    |> redirect(to: offer_path(conn, :show, slug))
  end

  @spec send_telegram(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def send_telegram(%Plug.Conn{} = conn, %{"slug" => slug}) when is_binary(slug) do
    offer = Core.get_offer_by_slug!(slug)

    case Telegram.send(conn, offer) do
      :ok ->
        conn
        |> put_flash(:info, gettext("<b>Offer correctly sent to Telegram channel!</b>"))
        |> redirect(to: offer_path(conn, :show, slug))

      error ->
        raise error
    end
  end

  @spec edit(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def edit(%Plug.Conn{} = conn, %{"slug" => slug}) when is_binary(slug) do
    offer = Core.get_offer_by_slug!(slug)
    offer_changeset = Core.change_offer(offer)

    render(conn, "edit.html", changeset: offer_changeset, offer: offer)
  end

  @spec update(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def update(%Plug.Conn{} = conn, %{"slug" => slug, "offer" => offer_params})
      when is_binary(slug) and is_map(offer_params) do
    offer = Core.get_offer_by_slug!(slug)

    case Core.update_offer(offer, offer_params) do
      {:ok, offer} ->
        conn
        |> put_flash(:info, gettext("<b>Job offer updated correctly!</b>"))
        |> redirect(to: offer_path(conn, :show, offer.slug))

      {:error, changeset} ->
        render(conn, "edit.html", changeset: changeset, offer: offer)
    end
  end

  @spec delete(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def delete(%Plug.Conn{} = conn, %{"slug" => slug}) when is_binary(slug) do
    slug
    |> Core.get_offer_by_slug!()
    |> Core.delete_offer()
    |> case do
      {:ok, _} ->
        conn
        |> put_flash(:info, gettext("<b>Job offer removed correctly!</b>"))
        |> redirect(to: admin_offer_path(conn, :index_published))

      {:error, _} ->
        conn
        |> put_flash(:error, gettext("<b>Job offer couldn't be removed correctly!</b>"))
        |> redirect(to: offer_path(conn, :show, slug))
    end
  end
end
