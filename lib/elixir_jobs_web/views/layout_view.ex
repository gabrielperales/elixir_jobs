defmodule ElixirJobsWeb.LayoutView do
  use ElixirJobsWeb, :view

  import Phoenix.Controller, only: [current_url: 1]

  alias ElixirJobsWeb.MicrodataHelper
  alias ElixirJobsWeb.SeoHelper
  alias ElixirJobsWeb.Telegram

  def get_flash_messages(%Plug.Conn{} = conn) do
    [:info, :error]
    |> Enum.map(&Phoenix.Flash.get(conn.assigns.flash, &1))
    |> Enum.filter(&(&1 != nil))
  end

  def get_telegram_channel, do: Telegram.get_channel()
end
