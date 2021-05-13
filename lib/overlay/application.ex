defmodule Overlay.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    IO.inspect(System.get_env("FILEPATH"), label: "filepath")

    children = [
      # Start the Ecto repository
      # Overlay.Repo,
      # Start the Telemetry supervisor
      OverlayWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Overlay.PubSub},
      {Overlay.Filewatch, dir: System.get_env("FILEPATH")},
      # Start the Endpoint (http/https)
      OverlayWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Overlay.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    OverlayWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
