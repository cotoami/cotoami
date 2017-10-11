defmodule Cotoami.CotonomaController do
  use Cotoami.Web, :controller
  require Logger
  alias Cotoami.{CotonomaService, CotoView}

  plug :scrub_params, "cotonoma" when action in [:create]

  def action(conn, _) do
    apply(__MODULE__, action_name(conn), [conn, conn.params, conn.assigns.amishi])
  end

  def index(conn, params, amishi) do
    cotonoma_id = params["cotonoma_id"]
    cotonomas = CotonomaService.find_by_amishi(amishi.id, cotonoma_id)
    render(conn, "index.json", %{rows: cotonomas})
  end

  def create(
    conn,
    %{
      "clientId" => clientId,
      "cotonoma" => %{
        "cotonoma_id" => cotonoma_id,
        "name" => name,
        "postId" => post_id
      }
    },
    amishi
  ) do
    {:ok, {{coto, cotonoma}, posted_in}} =
      Repo.transaction(fn ->
        case CotonomaService.create!(cotonoma_id, amishi.id, name) do
          {{coto, cotonoma}, nil} -> {{coto, cotonoma}, nil}
          {{coto, cotonoma}, posted_in} ->
            CotonomaService.increment_timeline_revision(posted_in)
            {{coto, cotonoma}, CotonomaService.get(posted_in.id, amishi.id)}
        end
      end)
    coto = %{coto |
      :posted_in => posted_in,
      :amishi => amishi,
      :cotonoma => cotonoma
    }
    if posted_in do
      broadcast_post(coto, posted_in.key, clientId)
    end
    render(conn, CotoView, "created.json", coto: coto, postId: post_id)
  end

  def cotos(conn, %{"key" => key}, amishi) do
    case CotonomaService.get_cotos(key, amishi) do
      nil ->
        send_resp(conn, :not_found, "")
      {cotos, cotonoma} ->
        render(conn, "cotos.json", %{cotos: cotos, cotonoma: cotonoma})
    end
  end
end
