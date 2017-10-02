defmodule Cotoami.CotonomaService do
  @moduledoc """
  Provides Cotonoma related functions.
  """

  require Logger
  import Ecto.Query, only: [preload: 2, where: 3, limit: 2]
  alias Cotoami.{Repo, Coto, Cotonoma, Amishi, AmishiService}

  def create!(cotonoma_id_nillable, amishi_id, name) do
    posted_in = check_permission!(cotonoma_id_nillable, amishi_id)
    {:ok, {coto, cotonoma}} =
      Repo.transaction(fn ->
        coto =
          %Coto{}
          |> Coto.changeset_to_insert(%{
              posted_in_id: cotonoma_id_nillable,
              amishi_id: amishi_id,
              content: name,
              as_cotonoma: true
            })
          |> Repo.insert!

        cotonoma =
          %Cotonoma{}
          |> Cotonoma.changeset_to_insert(%{
              name: name,
              coto_id: coto.id,
              owner_id: amishi_id
            })
          |> Repo.insert!
        cotonoma = %{cotonoma | coto: coto}
        coto = %{coto | cotonoma: cotonoma}

        {coto, cotonoma}
      end)
    {{coto, cotonoma}, posted_in}
  end

  defp base_query_for_amishi(amishi_id) do
    Cotonoma
    |> Cotonoma.for_amishi(amishi_id)
    |> preload([:coto, :owner])
  end

  defp append_gravatar_profile_to_owner(cotonoma) do
    if cotonoma do
      %{cotonoma | :owner => AmishiService.append_gravatar_profile(cotonoma.owner)}
    else
      nil
    end
  end

  def get(id, amishi_id) do
    amishi_id
    |> base_query_for_amishi()
    |> Repo.get(id)
    |> append_gravatar_profile_to_owner()
  end

  def get_by_key(key, amishi_id) do
    amishi_id
    |> base_query_for_amishi()
    |> Repo.get_by(key: key)
    |> append_gravatar_profile_to_owner()
  end

  def check_permission!(nil, _amishi_id) do
    nil
  end
  def check_permission!(cotonoma_id, amishi_id) do
    case check_permission(cotonoma_id, amishi_id) do
      nil -> raise "Forbidden cotonoma: #{cotonoma_id}"
      cotonoma -> cotonoma
    end
  end

  def check_permission(cotonoma_id, amishi_id) do
    Cotonoma
    |> Cotonoma.for_amishi(amishi_id)
    |> where([c], c.id == ^cotonoma_id)
    |> Repo.one()
  end

  def find_by_amishi(amishi_id, cotonoma_id_nillable) do
    amishi_id
    |> base_query_for_amishi()
    |> Cotonoma.in_cotonoma_if_specified(cotonoma_id_nillable)
    |> limit(100)
    |> Repo.all()
    |> Enum.map(&append_gravatar_profile_to_owner(&1))
  end

  def get_cotos(key, %Amishi{id: amishi_id} = amishi) do
    case get_by_key(key, amishi_id) do
      nil -> nil
      cotonoma ->
        if check_permission(cotonoma.id, amishi_id) do
          cotos =
            Coto
            |> Coto.in_cotonoma(cotonoma.id)
            |> preload([:amishi, :posted_in, :cotonoma])
            |> limit(100)
            |> Repo.all
            |> Enum.map(&(complement_gravatar(&1, amishi)))
          {cotos, cotonoma}
        else
          nil
        end
    end
  end

  defp complement_gravatar(coto, %Amishi{id: amishi_id} = amishi) do
    if coto.amishi.id == amishi_id do
      %{coto | :amishi => amishi}
    else
      another_amishi = AmishiService.append_gravatar_profile(coto.amishi)
      %{coto | :amishi => another_amishi}
    end
  end
end
