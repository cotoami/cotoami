defmodule Cotoami.CotoController do
  use Cotoami.Web, :controller
  require Logger
  import Cotoami.CotonomaService, only: [increment_timeline_revision: 1]
  alias Cotoami.{Coto, CotoService, CotonomaService, CotoGraphService}

  plug :scrub_params, "coto" when action in [:create, :update]

  def action(conn, _) do
    apply(__MODULE__, action_name(conn), [conn, conn.params, conn.assigns.amishi])
  end

  def index(conn, _params, amishi) do
    paginated_results = CotoService.get_cotos_by_amishi(amishi, 30, 0)
    render(conn, "index.json", paginated_results)
  end

  def create(
    conn,
    %{
      "clientId" => clientId,
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
      broadcast_post(coto, posted_in.key, clientId)
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
    render(conn, "coto.json", coto: coto)
  rescue
    e in Ecto.ConstraintError -> send_resp_by_constraint_error(conn, e)
  end

  def cotonomatize(conn, %{"id" => id}, amishi) do
    case CotoService.get_by_amishi(id, amishi) do
      %Coto{as_cotonoma: false} = coto ->
        {:ok, coto} = do_cotonomatize(coto, amishi)
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
    Repo.transaction(fn ->
      case CotoService.delete!(id, amishi) do
        nil -> nil
        posted_in -> increment_timeline_revision(posted_in)
      end
    end)
    send_resp(conn, :no_content, "")
  end
end
