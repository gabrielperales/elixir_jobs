defmodule ElixirJobsWeb.EmailView do
  use ElixirJobsWeb, :view

  import ElixirJobsWeb.OfferView, only: [human_get_place: 2, human_get_type: 2]
end
