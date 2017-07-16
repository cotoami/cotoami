defmodule Cotoami do
  use Application
  require Logger
  require Prometheus.Registry

  def start(_type, _args) do
    import Supervisor.Spec

    redix_workers = for i <- 0..(Cotoami.Redix.redix_pool_size() - 1) do
      worker(
        Redix,
        [[host: Cotoami.Redix.host(), port: Cotoami.Redix.port()],
         [name: :"redix_#{i}"]],
        id: {Redix, i}
      )
    end

    children = [
      supervisor(Cotoami.Repo, []),
      supervisor(Cotoami.Endpoint, []),
      supervisor(Cotoami.Presence, []),
      worker(Bolt.Sips, [Application.get_env(:bolt_sips, Bolt)])
    ] ++ redix_workers

    # Prometheus
    Cotoami.Endpoint.Instrumenter.setup()
    Cotoami.Endpoint.PipelineInstrumenter.setup()
    Cotoami.Repo.Instrumenter.setup()
    Cotoami.PrometheusExporter.setup()
    # https://github.com/deadtrickster/prometheus_process_collector/issues/2
    case :os.type do
      {:unix, :linux} ->
        Prometheus.Registry.register_collector(:prometheus_process_collector)
      _ -> nil
    end

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
