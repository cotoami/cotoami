defmodule CotoamiWeb.CotonomaController do
  use CotoamiWeb, :controller
  require Logger
  alias Cotoami.Cotonoma
  alias Cotoami.CotoService
  alias Cotoami.CotonomaService
  alias Cotoami.RichCotonomaService
  alias CotoamiWeb.CotoView

  plug(:scrub_params, "cotonoma" when action in [:create])

  def action(conn, _) do
    apply(__MODULE__, action_name(conn), [conn, conn.params, conn.assigns.amishi])
  end

  def index(conn, _params, amishi) do
    render(conn, "index.json", %{
      global: RichCotonomaService.global_cotonomas(amishi),
      recent: RichCotonomaService.recent_cotonomas(amishi)
    })
  end

  def super_and_sub(conn, %{"cotonoma_id" => cotonoma_id}, amishi) do
    cotonoma = CotonomaService.get_accessible!(cotonoma_id, amishi)

    render(conn, "super_and_sub.json", %{
      super: RichCotonomaService.super_cotonomas(cotonoma, amishi),
      sub: RichCotonomaService.sub_cotonomas(cotonoma.id, amishi)
    })
  end

  def suggest(conn, %{"query" => query}, amishi) do
    render(conn, "cotonomas.json", %{
      cotonomas: CotonomaService.suggest(amishi, query)
    })
  end

  def create(conn, %{"cotonoma" => cotonoma_params}, amishi) do
    %{"name" => name, "shared" => shared} = cotonoma_params

    coto =
      case get_cotonoma_if_specified!(cotonoma_params, amishi) do
        nil -> CotonomaService.create!(name, shared, amishi)
        cotonoma -> CotonomaService.create!(name, shared, amishi, cotonoma)
      end

    on_coto_created(conn, coto, amishi)
    render(conn, CotoView, "created.json", coto: coto)
  rescue
    e in Ecto.ConstraintError ->
      send_resp_by_constraint_error(conn, e)
  end

  def get(conn, %{"name" => name}, amishi) do
    case CotonomaService.get_by_name(name, amishi) do
      nil -> send_resp(conn, :not_found, "")
      cotonoma -> render(conn, "cotonoma.json", cotonoma: cotonoma)
    end
  end

  def get(conn, %{"key_or_name" => key_or_name}, amishi) do
    case CotonomaService.get_accessible_by_key_or_name(key_or_name, amishi) do
      nil -> send_resp(conn, :not_found, "")
      cotonoma -> render(conn, "cotonoma.json", cotonoma: cotonoma)
    end
  end

  def get_or_create(conn, %{"name" => name}, amishi) do
    coto = CotonomaService.create!(name, false, amishi)
    on_coto_created(conn, coto, amishi)
    render(conn, "cotonoma.json", cotonoma: coto.cotonoma)
  rescue
    e in Ecto.ConstraintError ->
      case e.constraint do
        "cotonomas_name_owner_id_index" ->
          cotonoma = CotonomaService.get_by_name(name, amishi)
          render(conn, "cotonoma.json", cotonoma: cotonoma)

        constraint ->
          send_resp(conn, :bad_request, constraint)
      end
  end

  @cotos_options ["exclude_pinned_graph"]

  def cotos(conn, %{"key" => key, "page" => page} = params, amishi) do
    cotonoma = RichCotonomaService.get_accessible_by_key!(key, amishi)
    page_index = String.to_integer(page)
    options = get_flags_in_params(params, @cotos_options)

    paginated_cotos =
      CotoService.all_by_cotonoma(cotonoma, amishi, page_index, options)
      |> Map.put(:cotonoma, cotonoma)

    render(conn, "cotos.json", paginated_cotos)
  end

  def random(conn, %{"key" => key} = params, amishi) do
    cotonoma = CotonomaService.get_accessible_by_key!(key, amishi)
    options = get_flags_in_params(params, @cotos_options)
    cotos = CotoService.random_by_cotonoma(cotonoma, amishi, options)
    render(conn, "random.json", cotos: cotos)
  end

  def stats(conn, %{"key" => key}, _amishi) do
    stats =
      Cotonoma
      |> Repo.get_by!(key: key)
      |> CotonomaService.stats()

    json(conn, stats)
  end
end
