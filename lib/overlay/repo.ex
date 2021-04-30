defmodule Overlay.Repo do
  use Ecto.Repo,
    otp_app: :overlay,
    adapter: Ecto.Adapters.Postgres
end
