defmodule Cotoami.RichCotonomaService do
  @moduledoc """
  Provides Cotonoma related functions with eager fetching.
  """

  require Logger
  import Ecto.Query, warn: false

  alias Cotoami.Repo
  alias Cotoami.Amishi
  alias Cotoami.Cotonoma
  alias Cotoami.CotonomaService
  alias Cotoami.AmishiService
  alias Cotoami.CotoGraphService

  def get_accessible_by_key!(key, %Amishi{} = amishi) do
    CotonomaService.get_accessible_by_key!(key, amishi)
    |> Repo.preload(coto: [:posted_in])
    |> set_reposted_in(amishi)
  end

  def map_by_ids(ids, %Amishi{} = amishi) do
    from(c in Cotonoma, where: c.id in ^ids)
    |> do_query_for_cotonomas(amishi)
    |> Enum.map(&{&1.id, &1})
    |> Map.new()
  end

  def map_by_keys(keys, %Amishi{} = amishi) do
    from(c in Cotonoma, where: c.key in ^keys)
    |> do_query_for_cotonomas(amishi)
    |> Enum.map(&{&1.key, &1})
    |> Map.new()
  end

  def recent_cotonomas(%Amishi{id: amishi_id} = amishi) do
    Cotonoma
    |> where([c], c.owner_id == ^amishi_id)
    |> limit(100)
    |> do_query_for_cotonomas(amishi)
  end

  def sub_cotonomas(cotonoma_id, %Amishi{} = amishi) do
    Cotonoma
    |> Cotonoma.in_cotonoma(cotonoma_id)
    |> limit(100)
    |> do_query_for_cotonomas(amishi)
  end

  def global_cotonomas(%Amishi{} = amishi) do
    case global_cotonomas_holder_amishi() do
      nil ->
        []

      holder_amishi ->
        keys = CotoGraphService.pinned_cotonoma_keys(Bolt.Sips.conn(), holder_amishi)
        cotonomas = map_by_keys(keys, amishi)
        for key <- keys, cotonomas[key], do: cotonomas[key]
    end
  end

  defp global_cotonomas_holder do
    :cotoami
    |> Application.get_env(__MODULE__, [])
    |> Keyword.get(:global_cotonomas_holder)
  end

  defp global_cotonomas_holder_amishi do
    case global_cotonomas_holder() do
      nil ->
        nil

      id_or_email ->
        case UUID.info(id_or_email) do
          {:ok, _info} ->
            AmishiService.get(id_or_email)

          {:error, _reason} ->
            AmishiService.get_by_email(id_or_email)
        end
    end
  end

  defp do_query_for_cotonomas(query, amishi) do
    query
    |> preload(coto: [:posted_in], owner: [])
    |> order_by(desc: :updated_at)
    |> Repo.all()
    |> set_reposted_in(amishi)
  end

  defp set_reposted_in(%Cotonoma{} = cotonoma, %Amishi{} = amishi) do
    [updated_cotonoma] = set_reposted_in([cotonoma], amishi)
    updated_cotonoma
  end

  defp set_reposted_in(cotonomas, %Amishi{} = amishi) when is_list(cotonomas) do
    all_reposted_cotonomas =
      cotonomas
      |> Enum.map(& &1.coto.reposted_in_ids)
      |> List.flatten()
      |> Enum.uniq()
      |> CotonomaService.accessible_map_by_ids(amishi)

    cotonomas
    |> Enum.map(fn cotonoma ->
      reposted_in =
        cotonoma.coto.reposted_in_ids
        |> Enum.map(&all_reposted_cotonomas[&1])
        |> Enum.filter(& &1)

      Map.put(cotonoma, :reposted_in, reposted_in)
    end)
  end
end
