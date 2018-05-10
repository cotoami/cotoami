defmodule CotoamiWeb.PageController do
  use CotoamiWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
