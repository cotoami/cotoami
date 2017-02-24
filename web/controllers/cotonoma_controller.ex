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
  
  def index(conn, _params, amishi) do
    cotonomas = CotonomaService.find_by_amishi(amishi.id)
    render(conn, "index.json", %{rows: cotonomas})
  end
  
  def create(conn, %{"cotonoma" => cotonoma_params}, amishi) do
    cotonoma_id = cotonoma_params["cotonoma_id"]
    name = cotonoma_params["name"]
    members = cotonoma_params["members"] || []
    postId = cotonoma_params["postId"]
    {coto, cotonoma} = CotonomaService.create!(cotonoma_id, amishi.id, name, members)
    render(conn, CotoView, "created.json", 
      coto: %{coto | :cotonoma => cotonoma}, 
      postId: postId
    )
  end
  
  def cotos(conn, %{"key" => key}, amishi) do
    case CotonomaService.get_cotos(key, amishi.id) do
      nil ->
        send_resp(conn, :not_found, "")
      {cotonoma, cotos} ->
        render(conn, "cotos.json", %{cotonoma: cotonoma, cotos: cotos})
    end
  end
end
