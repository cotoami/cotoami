defmodule Cotoami.CotoService do
  @moduledoc """
  Provides Coto related functions.
  """

  require Logger
  import Ecto.Query
  alias Cotoami.{
    Repo, Coto, Cotonoma, Amishi,
    AmishiService, CotonomaService, CotoGraphService
  }
  alias Cotoami.Exceptions.InvalidOperation

  def get(id) do
    Coto
    |> preload([:amishi, :posted_in, :cotonoma])
    |> Repo.get(id)
  end

  def get_by_ids(coto_ids) do
    Coto
    |> where([c], c.id in ^coto_ids)
    |> preload([:amishi, :posted_in, :cotonoma])
    |> Repo.all()
  end

  def get_by_amishi(id, %Amishi{id: amishi_id} = amishi) do
    coto =
      Coto
      |> Coto.for_amishi(amishi_id)
      |> preload([:posted_in, :cotonoma])
      |> Repo.get(id)
    case coto do
      nil -> nil
      coto -> %{coto | amishi: amishi}
    end
  end

  def get_cotos_by_amishi(%Amishi{id: amishi_id} = amishi) do
    Coto
    |> Coto.for_amishi(amishi_id)
    |> preload([:posted_in, :cotonoma])
    |> limit(100)
    |> Repo.all()
    |> Enum.map(&(complement_amishi(&1, amishi)))
  end

  def complement_amishi(%Coto{} = coto, %Amishi{id: amishi_id} = amishi) do
    if coto.amishi_id == amishi_id do
      %{coto | amishi: amishi}
    else
      case coto.amishi do
        %Ecto.Association.NotLoaded{} ->
          %{coto | amishi: AmishiService.get(coto.amishi_id)}
        amishi ->
          %{coto | amishi: AmishiService.append_gravatar_profile(amishi)}
      end
    end
  end

  def export_by_amishi(%Amishi{id: amishi_id}) do
    Coto
    |> Coto.for_amishi(amishi_id)
    |> preload([:posted_in, :cotonoma])
    |> Repo.all()
  end

  def create!(%Amishi{id: amishi_id}, content, summary \\ nil, cotonoma_id \\ nil) do
    posted_in = CotonomaService.get!(cotonoma_id)
    coto =
      %Coto{}
      |> Coto.changeset_to_insert(%{
          content: content,
          summary: summary,
          as_cotonoma: false,
          posted_in_id: cotonoma_id,
          amishi_id: amishi_id
        })
      |> Repo.insert!
    {coto, posted_in}
  end

  def update_content!(id, %{"content" => _} = params, %Amishi{id: amishi_id} = amishi) do
    Coto
    |> Coto.for_amishi(amishi_id)
    |> Repo.get!(id)
    |> Coto.changeset_to_update_content(params)
    |> Repo.update!()

    coto = get(id)  # updated struct with the relations
    if coto.as_cotonoma do
      coto.cotonoma
      |> Cotonoma.changeset_to_update_name(%{name: coto.content})
      |> Repo.update!()
    end

    CotoGraphService.sync_coto_props(Bolt.Sips.conn, coto)

    %{coto | posted_in: CotonomaService.complement_owner(coto.posted_in)}
    |> complement_amishi(amishi)
  end

  def delete!(id, %Amishi{id: amishi_id}) do
    coto =
      Coto
      |> Coto.for_amishi(amishi_id)
      |> preload([:posted_in, :cotonoma])
      |> Repo.get!(id)

    if coto.cotonoma do
      case CotonomaService.stats(coto.cotonoma) do
        %{cotos: 0, connections: 0} -> Repo.delete!(coto.cotonoma)
        _ -> raise InvalidOperation
      end
    end
    Repo.delete!(coto)
    CotoGraphService.delete_coto(Bolt.Sips.conn, id)

    CotonomaService.complement_owner(coto.posted_in)
  end
end
