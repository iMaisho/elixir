import Config

env_db_user =
  System.get_env("POSTGRES_USR") ||
    raise """
    environment variable POSTGRES_USR is missing.
    """

env_db_passwd =
  System.get_env("POSTGRES_PASSWD") ||
    raise """
    environment variable POSTGRES_PASSWD is missing.
    """

env_db_hostname =
  System.get_env("POSTGRES_HOSTNAME") ||
    raise """
    environment variable POSTGRES_HOSTNAME is missing.
    Example: localhost
    """

env_db_dbname =
  System.get_env("POSTGRES_DBNAME") ||
    raise """
    environment variable POSTGRES_DBNAME is missing.
    Example: my_app_website_dev
    """

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :testing, Testing.Repo,
  username: env_db_user,
  password: env_db_passwd,
  hostname: env_db_hostnamev,
  database: "testing_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :testing, TestingWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "17zTqdTmphZuC9XKe9yssEVrqanP3KzB9t5R7byFNOzXDntMCSEGUs11op8YKOqG",
  server: false

# In test we don't send emails
config :testing, Testing.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true
