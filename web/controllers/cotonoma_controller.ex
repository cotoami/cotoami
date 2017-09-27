defmodule Cotoami.CotonomaController do
  use Cotoami.Web, :controller
  require Logger
  alias Cotoami.{CotonomaService, CotoView, AmishiService}

  plug :scrub_params, "cotonoma" when action in [:create]

  def action(conn, _) do
    apply(__MODULE__, action_name(conn), [conn, conn.params, conn.assigns.amishi])
  end

  def index(conn, params, amishi) do
    cotonoma_id = params["cotonoma_id"]
    cotonomas = CotonomaService.find_by_amishi(amishi.id, cotonoma_id)
    render(conn, "index.json", %{rows: cotonomas})
  end

  def create(conn, %{"clientId" => clientId, "cotonoma" => cotonoma_params}, amishi) do
    cotonoma_id = cotonoma_params["cotonoma_id"]
    name = cotonoma_params["name"]
    members = cotonoma_params["members"] || []
    post_id = cotonoma_params["postId"]

    {{coto, cotonoma}, posted_in} =
      CotonomaService.create!(cotonoma_id, amishi.id, name, members)

    full_fledged_coto = %{coto |
      :posted_in => posted_in,
      :amishi => AmishiService.append_gravatar_profile(amishi),
      :cotonoma => cotonoma
    }

    if posted_in do
      full_fledged_coto |> broadcast_post(posted_in.key, clientId)
    end

    render(conn, CotoView, "created.json",
      coto: full_fledged_coto,
      postId: post_id
    )
  end

  def cotos(conn, %{"key" => key}, amishi) do
    case CotonomaService.get_cotos(key, amishi) do
      nil ->
        send_resp(conn, :not_found, "")
      {cotos, cotonoma, members} ->
        render(conn, "cotos.json",
          %{cotos: cotos, cotonoma: cotonoma, members: members}
        )
    end
  end
end
