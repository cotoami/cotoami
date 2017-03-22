defmodule Cotoami.CotonomaService do
  require Logger
  import Ecto.Query, only: [preload: 2, where: 3, limit: 2]
  alias Cotoami.Repo
  alias Cotoami.Coto
  alias Cotoami.Cotonoma
  alias Cotoami.Member
  alias Cotoami.AmishiService
  
  def create!(cotonoma_id, amishi_id, name, member_params) do
    # TODO: check cotonoma membership
    {:ok, {coto, cotonoma}} =
      Repo.transaction(fn ->
        coto = 
          Coto.changeset(%Coto{}, %{
            posted_in_id: cotonoma_id,
            amishi_id: amishi_id,
            content: name,
            as_cotonoma: true
          }) |> Repo.insert!
          
        cotonoma =
          Cotonoma.changeset_new(%Cotonoma{}, %{
            name: name,
            coto_id: coto.id,
            owner_id: amishi_id
          }) |> Repo.insert!
          
        members = 
          member_params
          |> Enum.map(&add_member(cotonoma, &1))
          |> Enum.filter(&(&1 != nil))
        cotonoma = %{cotonoma | members: members}
          
        {coto, cotonoma}
      end)
    {coto, cotonoma}
  end
  
  def add_member(cotonoma, member_param) do
    case member_param do
      %{"amishi_id" => amishi_id} ->
        case AmishiService.get(amishi_id) do
          nil -> 
            nil
          amishi -> 
            Member.changeset(%Member{}, %{
              cotonoma_id: cotonoma.id,
              amishi_id: amishi.id,
              email: amishi.email
            }) |> Repo.insert!
        end
        
      %{"email" => email} ->
        Member.changeset(%Member{}, %{
          cotonoma_id: cotonoma.id,
          email: email
        }) |> Repo.insert!
        
      _ ->
        nil
    end
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
    base_query_for_amishi(amishi_id) 
    |> Repo.get(id)
    |> append_gravatar_profile_to_owner()
  end
  
  def get_by_key(key, amishi_id) do
    base_query_for_amishi(amishi_id) 
    |> Repo.get_by(key: key)
    |> append_gravatar_profile_to_owner()
  end
  
  def check_permission!(nil, amishi_id) do
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
    base_query_for_amishi(amishi_id)
    |> Cotonoma.in_cotonoma_if_specified(cotonoma_id_nillable)
    |> limit(100)
    |> Repo.all()
    |> Enum.map(&append_gravatar_profile_to_owner(&1))
  end
  
  def get_members(cotonoma_id) do
    Member
    |> Member.for_cotonoma(cotonoma_id)
    |> preload([:amishi])
    |> Repo.all()
    |> Enum.map(&(&1.amishi))
    |> Enum.map(&AmishiService.append_gravatar_profile(&1))
  end
  
  def get_cotos(key, amishi_id) do
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
            |> Enum.map(fn(coto) ->
              if coto.amishi.id != amishi_id do
                anotherAmishi = AmishiService.append_gravatar_profile(coto.amishi)
                %{coto | :amishi => anotherAmishi}
              else
                coto
              end
            end)
          members = get_members(cotonoma.id)
          {cotos, cotonoma, members}
        else
          nil
        end
    end
  end
end
