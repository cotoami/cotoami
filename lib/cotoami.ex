defmodule Cotoami do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      supervisor(Cotoami.Repo, []),
      supervisor(Cotoami.Endpoint, []),
    ]
    
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
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    Cotoami.Endpoint.config_change(changed, removed)
    :ok
  end
end
