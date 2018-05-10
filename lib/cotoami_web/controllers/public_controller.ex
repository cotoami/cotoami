defmodule CotoamiWeb.PublicController do
  use CotoamiWeb, :controller
  require Logger

  plug Logster.Plugs.ChangeLogLevel, to: :debug

  @version Mix.Project.config[:version]

  def index(conn, _params) do
    text conn, @version
  end
end
