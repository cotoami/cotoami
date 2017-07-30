defmodule Cotoami.Endpoint.PipelineInstrumenter do
  @moduledoc """
  Collects http metrics.
  """

  use Prometheus.PlugPipelineInstrumenter

  def label_value(:request_path, conn) do
    conn.request_path
  end
end
