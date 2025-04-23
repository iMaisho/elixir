defmodule FrixelIntro.Repo do
  use Ecto.Repo,
    otp_app: :frixel_intro,
    adapter: Ecto.Adapters.Postgres
end
