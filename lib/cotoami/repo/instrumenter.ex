defmodule Cotoami.Repo.Instrumenter do
  @moduledoc """
  Ecto instrumenter generator for Prometheus. Implemented as Ecto logger.
  """

  use Prometheus.EctoInstrumenter
end
