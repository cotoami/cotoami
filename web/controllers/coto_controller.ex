defmodule Cotoami.CotoController do
  use Cotoami.Web, :controller
  require Logger
  alias Cotoami.{Coto, CotoService, CotonomaService}

  plug :scrub_params, "coto" when action in [:create, :update]

  def action(conn, _) do
    apply(__MODULE__, action_name(conn), [conn, conn.params, conn.assigns.amishi])
  end

  def index(conn, _params, amishi) do
    cotos = CotoService.get_cotos_by_amishi(amishi)
    render(conn, "index.json", %{rows: cotos})
  end

  def create(
    conn,
    %{
      "clientId" => clientId,
      "coto" => %{
        "cotonoma_id" => cotonoma_id,
        "content" => content,
        "postId" => post_id
      }
    },
    amishi
  ) do
    {:ok, {coto, posted_in}} =
      Repo.transaction(fn ->
        case CotoService.create!(content, amishi.id, cotonoma_id) do
          {coto, nil} -> {coto, nil}
          {coto, posted_in} ->
            posted_in
            |> CotonomaService.increment_timeline_revision()
            |> CotonomaService.complement_owner()
            |> (fn (posted_in) -> {coto, posted_in} end).()
        end
      end)
    coto = %{coto | posted_in: posted_in, amishi: amishi}
    if posted_in do
      broadcast_post(coto, posted_in.key, clientId)
    end
    render(conn, "created.json", coto: coto, postId: post_id)
  end

  def update(conn, %{"id" => id, "coto" => coto_params}, amishi) do
    {:ok, coto} = do_update!(id, coto_params, amishi)
    render(conn, "coto.json", coto: coto)
  rescue
    e in Ecto.ConstraintError -> send_resp_by_constraint_error(conn, e)
  end

  defp do_update!(id, coto_params, amishi) do
    Repo.transaction(fn ->
      case CotoService.update_content!(id, coto_params, amishi) do
        %Coto{posted_in: nil} = coto -> coto
        %Coto{posted_in: posted_in} = coto ->
          posted_in
          |> CotonomaService.increment_timeline_revision()
          |> CotonomaService.complement_owner()
          |> (fn (posted_in) -> %{coto | posted_in: posted_in} end).()
      end
    end)
  end

  def delete(conn, %{"id" => id}, amishi) do
    CotoService.delete(id, amishi)
    send_resp(conn, :no_content, "")
  end
end
