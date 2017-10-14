defmodule Cotoami.CotonomaController do
  use Cotoami.Web, :controller
  require Logger
  alias Cotoami.{Cotonoma, CotonomaService, CotoView}

  plug :scrub_params, "cotonoma" when action in [:create]

  def action(conn, _) do
    apply(__MODULE__, action_name(conn), [conn, conn.params, conn.assigns.amishi])
  end

  def index(conn, _params, _amishi) do
    render(conn, "index.json", %{
      pinned: CotonomaService.pinned_cotonomas(),
      recent: CotonomaService.recent_cotonomas(),
    })
  end

  def sub(conn, %{"cotonoma_id" => cotonoma_id}, _amishi) do
    render(conn, "sub.json", %{
      rows: CotonomaService.recent_cotonomas(cotonoma_id)
    })
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
    try do
      {:ok, {{coto, _cotonoma}, posted_in}} =
        do_create!(name, amishi, cotonoma_id)
      if posted_in do
        broadcast_post(coto, posted_in.key, clientId)
      end
      render(conn, CotoView, "created.json", coto: coto, postId: post_id)
    rescue
        e in Ecto.ConstraintError ->
          case e.constraint do
            "cotonomas_name_owner_id_index" ->
              send_resp(conn, :conflict, "")
            constraint ->
              send_resp(conn, :bad_request, constraint)
          end
    end
  end

  defp do_create!(name, amishi, cotonoma_id) do
    Repo.transaction(fn ->
      case CotonomaService.create!(name, amishi, cotonoma_id) do
        {{coto, cotonoma}, nil} -> {{coto, cotonoma}, nil}
        {{coto, cotonoma}, posted_in} ->
          posted_in
          |> CotonomaService.increment_timeline_revision()
          |> CotonomaService.complement_owner()
          |> (fn (posted_in) -> {{coto, cotonoma}, posted_in} end).()
      end
    end)
  end

  def pin(conn, %{"key" => key}, %{owner: true}) do
    Cotonoma |> Repo.get_by!(key: key) |> CotonomaService.pin()
    send_resp(conn, :ok, "")
  end

  def unpin(conn, %{"key" => key}, %{owner: true}) do
    Cotonoma |> Repo.get_by!(key: key) |> CotonomaService.unpin()
    send_resp(conn, :ok, "")
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
