defmodule Cotoami.CotonomaController do
  use Cotoami.Web, :controller
  require Logger
  import Cotoami.CotonomaService, only: [increment_timeline_revision: 1]
  alias Cotoami.{Cotonoma, CotoService, CotonomaService, CotoView}

  plug :scrub_params, "cotonoma" when action in [:create]

  def action(conn, _) do
    apply(__MODULE__, action_name(conn), [conn, conn.params, conn.assigns.amishi])
  end

  def index(conn, _params, amishi) do
    render(conn, "index.json", %{
      pinned: CotonomaService.pinned_cotonomas(),
      recent: CotonomaService.recent_cotonomas(amishi),
    })
  end

  def sub(conn, %{"cotonoma_id" => cotonoma_id}, _amishi) do
    render(conn, "sub.json", %{
      rows: CotonomaService.sub_cotonomas(cotonoma_id)
    })
  end

  def create(
    conn,
    %{
      "cotonoma" => %{
        "cotonoma_id" => cotonoma_id,
        "name" => name
      }
    },
    amishi
  ) do
    {:ok, {cotonoma_coto, posted_in}} =
      Repo.transaction(fn ->
        case CotonomaService.create!(amishi, name, cotonoma_id) do
          {cotonoma_coto, nil} -> {cotonoma_coto, nil}
          {cotonoma_coto, posted_in} ->
            {cotonoma_coto, increment_timeline_revision(posted_in)}
        end
      end)
    if posted_in do
      broadcast_post(cotonoma_coto, posted_in.key, amishi, conn.assigns.client_id)
    end
    render(conn, CotoView, "created.json", coto: cotonoma_coto)
  rescue
    e in Ecto.ConstraintError ->
      send_resp_by_constraint_error(conn, e)
  end

  def pin(conn, %{"key" => key}, %{owner: true}) do
    Cotonoma |> Repo.get_by!(key: key) |> CotonomaService.pin()
    conn |> put_status(:ok) |> json("")
  end

  def unpin(conn, %{"key" => key}, %{owner: true}) do
    Cotonoma |> Repo.get_by!(key: key) |> CotonomaService.unpin()
    conn |> put_status(:ok) |> json("")
  end

  def cotos(conn, %{"key" => key, "page" => page}, amishi) do
    page_index = String.to_integer(page)
    case CotoService.get_cotos_by_cotonoma(key, amishi, page_index) do
      nil ->
        send_resp(conn, :not_found, "")
      paginated_results ->
        render(conn, "cotos.json", paginated_results)
    end
  end

  def stats(conn, %{"key" => key}, _amishi) do
    stats =
      Cotonoma
      |> Repo.get_by!(key: key)
      |> CotonomaService.stats()
    json conn, stats
  end
end
