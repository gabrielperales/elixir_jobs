defmodule ElixirJobsWeb.HumanizeHelper do
  @moduledoc false
  use ElixirJobsWeb, :helper

  alias ElixirJobsWeb.DateHelper

  def human_get_place("onsite", default), do: get_place_text(:onsite, default)
  def human_get_place("remote", default), do: get_place_text(:remote, default)
  def human_get_place("both", default), do: get_place_text(:both, default)
  def human_get_place(option, default), do: get_place_text(option, default)

  def human_get_type("full_time", default), do: get_type_text(:full_time, default)
  def human_get_type("part_time", default), do: get_type_text(:part_time, default)
  def human_get_type("freelance", default), do: get_type_text(:freelance, default)
  def human_get_type(option, default), do: get_type_text(option, default)

  @doc "Returns a date formatted for humans."
  @spec readable_date(DateTime.t()) :: String.t()
  @spec readable_date(DateTime.t(), boolean()) :: String.t()
  def readable_date(%DateTime{} = date, use_abbrevs? \\ true) do
    if use_abbrevs? && this_year?(date) do
      cond do
        today?(date) ->
          "Today"

        yesterday?(date) ->
          "Yesterday"

        true ->
          DateHelper.strftime(date, "%e %b")
      end
    else
      DateHelper.strftime(date, "%e %b %Y")
    end
  end

  def get_place_text(:onsite, _default), do: gettext("On site")
  def get_place_text(:remote, _default), do: gettext("Remote")
  def get_place_text(:both, _default), do: gettext("Onsite / Remote")
  def get_place_text(_, default), do: default

  def get_type_text(:full_time, _default), do: gettext("Full time")
  def get_type_text(:part_time, _default), do: gettext("Part time")
  def get_type_text(:freelance, _default), do: gettext("Freelance")
  def get_type_text(_, default), do: default

  ###
  # Private functions
  ###

  @spec this_year?(DateTime.t()) :: boolean()
  defp this_year?(%DateTime{} = date), do: date.year == DateTime.utc_now().year

  @spec today?(DateTime.t()) :: boolean()
  defp today?(%DateTime{} = date) do
    now = DateTime.utc_now()
    date.day == now.day && date.month == now.month && date.year == now.year
  end

  @spec yesterday?(DateTime.t()) :: boolean()
  defp yesterday?(%DateTime{} = date) do
    now = DateTime.utc_now()
    difference = DateTime.diff(now, date)
    difference < 2 * 24 * 60 * 60 && difference > 1 * 24 * 60 * 60
  end
end
