defmodule Cotoami.CotoController do
  use Cotoami.Web, :controller
  require Logger
  import Cotoami.CotonomaService, only: [increment_timeline_revision: 1]
  alias Cotoami.{Coto, CotoService, CotonomaService, CotoGraphService}

  plug :scrub_params, "coto" when action in [:create, :update]

  def action(conn, _) do
    apply(__MODULE__, action_name(conn), [conn, conn.params, conn.assigns.amishi])
  end

  def index(conn, %{"page" => page}, amishi) do
    page_index = String.to_integer(page)
    paginated_results = CotoService.get_cotos_by_amishi(amishi, page_index)
    render(conn, "cotos.json", paginated_results)
  end

  def create(
    conn,
    %{
      "coto" => %{
        "content" => content,
        "summary" => summary,
        "cotonoma_id" => cotonoma_id
      }
    },
    amishi
  ) do
    {:ok, {coto, posted_in}} =
      Repo.transaction(fn ->
        case CotoService.create!(amishi, content, summary, cotonoma_id) do
          {coto, nil} -> {coto, nil}
          {coto, posted_in} ->
            {coto, increment_timeline_revision(posted_in)}
        end
      end)
    coto = %{coto | posted_in: posted_in, amishi: amishi}
    if posted_in do
      broadcast_post(coto, posted_in.key, amishi, conn.assigns.client_id)
      broadcast_cotonoma(posted_in, amishi, conn.assigns.client_id)
    end
    render(conn, "created.json", coto: coto)
  end

  def update(conn, %{"id" => id, "coto" => coto_params}, amishi) do
    {:ok, coto} =
      Repo.transaction(fn ->
        case CotoService.update_content!(id, coto_params, amishi) do
          %Coto{posted_in: nil} = coto -> coto
          %Coto{posted_in: posted_in} = coto ->
            %{coto | posted_in: increment_timeline_revision(posted_in)}
        end
      end)
    broadcast_update(coto, amishi, conn.assigns.client_id)
    render(conn, "coto.json", coto: coto)
  rescue
    e in Ecto.ConstraintError -> send_resp_by_constraint_error(conn, e)
  end

  def cotonomatize(conn, %{"id" => id}, amishi) do
    case CotoService.get_by_amishi(id, amishi) do
      %Coto{as_cotonoma: false} = coto ->
        {:ok, coto} = do_cotonomatize(coto, amishi)

        # broadcast events
        broadcast_cotonomatize(coto.cotonoma, amishi, conn.assigns.client_id)
        if coto.cotonoma.graph_revision > 0 do
          # broadcast 'cotonoma' only if it's not empty
          broadcast_cotonoma(coto.cotonoma, amishi, conn.assigns.client_id)
        end
        if coto.posted_in do
          broadcast_cotonoma(coto.posted_in, amishi, conn.assigns.client_id)
        end

        render(conn, "coto.json", coto: coto)

      # Fix inconsistent state caused by the cotonomatizing-won't-affect-graph bug
      %Coto{as_cotonoma: true} = coto ->
        CotoGraphService.sync_coto_props(Bolt.Sips.conn, coto)
        render(conn, "coto.json", coto: coto)

      _ ->
        send_resp(conn, :not_found, "")
    end
  rescue
    e in Ecto.ConstraintError -> send_resp_by_constraint_error(conn, e)
  end

  defp do_cotonomatize(coto, amishi) do
    Repo.transaction(fn ->
      case CotonomaService.cotonomatize!(coto, amishi) do
        %Coto{posted_in: nil} = coto -> coto
        %Coto{posted_in: posted_in} = coto ->
          %{coto | posted_in: increment_timeline_revision(posted_in)}
      end
    end)
  end

  def delete(conn, %{"id" => id}, amishi) do
    {:ok, posted_in} = 
      Repo.transaction(fn ->
        case CotoService.delete!(id, amishi) do
          nil -> nil
          posted_in -> increment_timeline_revision(posted_in)
        end
      end)
    broadcast_delete(id, amishi, conn.assigns.client_id)
    if posted_in do
      broadcast_cotonoma(posted_in, amishi, conn.assigns.client_id)
    end
    send_resp(conn, :no_content, "")
  end
end
