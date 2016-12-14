defmodule Cotoami do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      supervisor(Cotoami.Repo, []),
      supervisor(Cotoami.Endpoint, []),
    ]

    opts = [strategy: :one_for_one, name: Cotoami.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    Cotoami.Endpoint.config_change(changed, removed)
    :ok
  end
end
