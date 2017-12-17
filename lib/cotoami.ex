defmodule Cotoami do
  @moduledoc """
  The entrypoint of Cotoami app
  """

  use Application
  require Logger

  def start(_type, _args) do
    import Supervisor.Spec

    redix_workers = for i <- 0..(Cotoami.Redix.redix_pool_size() - 1) do
      worker(
        Redix,
        [
          case Cotoami.Redix.url() do
            nil -> [host: Cotoami.Redix.host(), port: Cotoami.Redix.port()]
            url -> url
          end,
          [name: :"redix_#{i}"]
        ],
        id: {Redix, i}
      )
    end

    children = [
      supervisor(Cotoami.Repo, []),
      supervisor(Cotoami.Endpoint, []),
      supervisor(Cotoami.Presence, []),
      worker(Bolt.Sips, [Application.get_env(:bolt_sips, Bolt)])
    ] ++ redix_workers

    opts = [strategy: :one_for_one, name: Cotoami.Supervisor]
    start_result = Supervisor.start_link(children, opts)

    # Run migrations on start
    Logger.info "Running migrations on start..."
    Ecto.Migrator.run(Cotoami.Repo, "priv/repo/migrations", :up, all: true)

    start_result
  end

  def config_change(changed, _new, removed) do
    Cotoami.Endpoint.config_change(changed, removed)
    :ok
  end
end
