defmodule Cotoami.CotonomaController do
  use Cotoami.Web, :controller
  require Logger
  alias Cotoami.{CotonomaService, CotoView}

  plug :scrub_params, "cotonoma" when action in [:create]

  def action(conn, _) do
    apply(__MODULE__, action_name(conn), [conn, conn.params, conn.assigns.amishi])
  end

  def index(conn, params, _amishi) do
    cotonoma_id = params["cotonoma_id"]
    cotonomas = CotonomaService.recent_cotonomas(cotonoma_id)
    render(conn, "index.json", %{rows: cotonomas})
  end

  def pinned(conn, params, _amishi) do
    render(conn, "index.json", %{rows: CotonomaService.pinned_cotonomas()})
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
        case CotonomaService.create!(name, amishi.id, cotonoma_id) do
          {{coto, cotonoma}, nil} -> {{coto, cotonoma}, nil}
          {{coto, cotonoma}, posted_in} ->
            CotonomaService.increment_timeline_revision(posted_in)
            |> CotonomaService.complement_owner()
            |> (fn (posted_in) -> {{coto, cotonoma}, posted_in} end).()
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

  def pin(conn, %{"cotonoma_id" => cotonoma_id}, %{owner: true}) do
    Cotonoma |> Repo.get!(cotonoma_id) |> CotonomaService.pin()
    send_resp(conn, :ok, "")
  end

  def unpin(conn, %{"cotonoma_id" => cotonoma_id}, %{owner: true}) do
    Cotonoma |> Repo.get!(cotonoma_id) |> CotonomaService.unpin()
    send_resp(conn, :ok, "")
  end
end
