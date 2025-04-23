defmodule Testing.Repo do
  use Ecto.Repo,
    otp_app: :testing,
    adapter: Ecto.Adapters.Postgres
end
