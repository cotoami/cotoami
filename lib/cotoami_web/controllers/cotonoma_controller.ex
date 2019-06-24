defmodule CotoamiWeb.CotonomaController do
  use CotoamiWeb, :controller
  require Logger
  alias Cotoami.{Cotonoma, CotoService, CotonomaService}
  alias CotoamiWeb.CotoView

  plug(:scrub_params, "cotonoma" when action in [:create])

  def action(conn, _) do
    apply(__MODULE__, action_name(conn), [conn, conn.params, conn.assigns.amishi])
  end

  def index(conn, _params, amishi) do
    render(conn, "index.json", %{
      global: CotonomaService.global_cotonomas(),
      recent: CotonomaService.recent_cotonomas(amishi)
    })
  end

  def sub(conn, %{"cotonoma_id" => cotonoma_id}, _amishi) do
    render(conn, "cotonomas.json", %{
      cotonomas: CotonomaService.sub_cotonomas(cotonoma_id)
    })
  end

  def suggest(conn, %{"query" => query}, amishi) do
    render(conn, "cotonomas.json", %{
      cotonomas: CotonomaService.suggest(amishi, query)
    })
  end

  def create(
        conn,
        %{
          "cotonoma" => %{
            "cotonoma_id" => cotonoma_id,
            "name" => name,
            "shared" => shared
          }
        },
        amishi
      ) do
    coto = CotonomaService.create!(amishi, name, shared, cotonoma_id)
    on_coto_created(conn, coto, amishi)
    render(conn, CotoView, "created.json", coto: coto)
  rescue
    e in Ecto.ConstraintError ->
      send_resp_by_constraint_error(conn, e)
  end

  def get_or_create(conn, %{"name" => name}, amishi) do
    coto = CotonomaService.create!(amishi, name, false, nil)
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
    cotonoma = CotonomaService.get_by_key!(key, amishi)
    page_index = String.to_integer(page)
    options = get_flags_in_params(params, @cotos_options)
    paginated_cotos = CotoService.all_by_cotonoma(cotonoma, amishi, page_index, options)
    render(conn, "cotos.json", paginated_cotos |> Map.put(:cotonoma, cotonoma))
  end

  def random(conn, %{"key" => key} = params, amishi) do
    cotonoma = CotonomaService.get_by_key!(key, amishi)
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
