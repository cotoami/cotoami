defmodule CotoamiWeb.CotoController do
  use CotoamiWeb, :controller
  require Logger
  import Cotoami.CotonomaService, only: [increment_timeline_revision: 1]
  alias Cotoami.{Coto, CotoService, CotonomaService, CotoGraphService}

  plug(:scrub_params, "coto" when action in [:create, :update])

  def action(conn, _) do
    apply(__MODULE__, action_name(conn), [conn, conn.params, conn.assigns.amishi])
  end

  @index_options ["exclude_pinned_graph", "exclude_posts_in_cotonoma"]

  def index(conn, %{"page" => page} = params, amishi) do
    page_index = String.to_integer(page)
    options = get_flags_in_params(params, @index_options)
    paginated_results = CotoService.all_by_amishi(amishi, page_index, options)
    render(conn, "paginated_cotos.json", paginated_results)
  end

  def random(conn, params, amishi) do
    options = get_flags_in_params(params, @index_options)
    render(conn, "cotos.json", cotos: CotoService.random_by_amishi(amishi, options))
  end

  def search(conn, %{"query" => query}, amishi) do
    render(conn, "cotos.json", cotos: CotoService.search(query, amishi))
  end

  def create(conn, %{"coto" => coto_params}, amishi) do
    %{"content" => content, "summary" => summary} = coto_params

    coto =
      case get_cotonoma_if_specified!(coto_params, amishi) do
        nil -> CotoService.create!(content, summary, amishi)
        cotonoma -> CotoService.create!(content, summary, amishi, cotonoma)
      end

    on_coto_created(conn, coto, amishi)
    render(conn, "created.json", coto: coto)
  end

  def repost(conn, %{"id" => id, "cotonoma_name" => cotonoma_name}, amishi) do
    cotonoma =
      try do
        cotonoma_coto = CotonomaService.create!(cotonoma_name, false, amishi)
        on_coto_created(conn, cotonoma_coto, amishi)
        cotonoma_coto.cotonoma
      rescue
        _ in Ecto.ConstraintError ->
          CotonomaService.get_by_name(cotonoma_name, amishi)
      end

    repost =
      CotoService.get!(id)
      |> CotoService.repost!(amishi, cotonoma)

    on_coto_created(conn, repost, amishi)
    broadcast_coto_update(repost.repost, amishi, conn.assigns.client_id)
    render(conn, "created.json", coto: repost)
  end

  def repost(conn, %{"id" => id} = params, amishi) do
    coto = CotoService.get!(id)
    cotonoma = get_cotonoma_if_specified!(params, amishi)

    repost =
      case cotonoma do
        nil -> CotoService.repost!(coto, amishi)
        cotonoma -> CotoService.repost!(coto, amishi, cotonoma)
      end

    on_coto_created(conn, repost, amishi)
    broadcast_coto_update(repost.repost, amishi, conn.assigns.client_id)
    render(conn, "created.json", coto: repost)
  end

  def update(conn, %{"id" => id, "coto" => coto_params}, amishi) do
    {:ok, coto} =
      Repo.transaction(fn ->
        case CotoService.update!(id, coto_params, amishi) do
          %Coto{posted_in: nil} = coto ->
            coto

          %Coto{posted_in: posted_in} = coto ->
            %{coto | posted_in: increment_timeline_revision(posted_in)}
        end
      end)

    broadcast_coto_update(coto, amishi, conn.assigns.client_id)

    if coto.as_cotonoma do
      broadcast_cotonoma_update(coto.cotonoma, amishi, conn.assigns.client_id)
    end

    render(conn, "coto.json", coto: coto)
  rescue
    e in Ecto.ConstraintError -> send_resp_by_constraint_error(conn, e)
  end

  def cotonomatize(conn, %{"id" => id}, amishi) do
    case CotoService.get_by_amishi(id, amishi) do
      %Coto{as_cotonoma: false} = coto ->
        {:ok, coto} = do_cotonomatize(coto, amishi)
        broadcast_cotonomatize(coto.cotonoma, amishi, conn.assigns.client_id)
        render(conn, "coto.json", coto: coto)

      # Fix inconsistent state caused by the cotonomatizing-won't-affect-graph bug
      %Coto{as_cotonoma: true} = coto ->
        CotoGraphService.sync(Bolt.Sips.conn(), coto)
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
        %Coto{posted_in: nil} = coto ->
          coto

        %Coto{posted_in: posted_in} = coto ->
          %{coto | posted_in: increment_timeline_revision(posted_in)}
      end
    end)
  end

  def delete(conn, %{"id" => id}, amishi) do
    # all the reposts will be deleted by cascade
    repost_ids = CotoService.repost_ids(id)

    {:ok, coto} =
      Repo.transaction(fn ->
        coto = CotoService.delete!(id, amishi)

        if coto.posted_in do
          increment_timeline_revision(coto.posted_in)
        end

        coto
      end)

    broadcast_delete(id, amishi, conn.assigns.client_id)
    # By sending an empty client_id, force all clients to handle reposts delete
    repost_ids |> Enum.each(&broadcast_delete(&1, amishi, ""))

    if coto.repost do
      # Force all clients to handle derived update
      broadcast_coto_update(coto.repost, amishi, "")
    end

    send_resp(conn, :no_content, "")
  end
end
