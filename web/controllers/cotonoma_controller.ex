defmodule Cotoami.CotonomaController do
  use Cotoami.Web, :controller
  require Logger
  alias Cotoami.CotonomaService
  alias Cotoami.CotoView
  
  plug :scrub_params, "cotonoma" when action in [:create]
  
  # TODO: check if amishi exists
  
  def action(conn, _) do
    apply(__MODULE__, action_name(conn), [conn, conn.params, conn.assigns.amishi])
  end
  
  def create(conn, %{"cotonoma" => cotonoma_params}, amishi) do
    cotonoma_id = cotonoma_params["cotonoma_id"]
    name = cotonoma_params["name"]
    {coto, cotonoma} = CotonomaService.create!(cotonoma_id, amishi.id, name)
    CotoView.render(conn, "created.json", coto: coto, postId: cotonoma_params["postId"])
  end
end
