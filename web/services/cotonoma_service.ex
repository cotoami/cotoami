defmodule Cotoami.CotonomaService do
  require Logger
  import Ecto.Query, only: [preload: 2, where: 3]
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
  
  def get_by_key(key, amishi_id) do
    Cotonoma
    |> Cotonoma.for_amishi(amishi_id)
    |> preload([:coto])
    |> Repo.get_by(key: key)
  end
  
  def check_permission(cotonoma, amishi_id) do
    Cotonoma
    |> Cotonoma.for_amishi(amishi_id)
    |> where([c], c.id == ^cotonoma.id)
    |> Repo.one()
  end
  
  def find_by_amishi(amishi_id, cotonoma_id_nillable) do
    Cotonoma
    |> Cotonoma.for_amishi(amishi_id)
    |> Cotonoma.in_cotonoma_if_specified(cotonoma_id_nillable)
    |> preload([:coto])
    |> Repo.all()
  end
  
  def get_cotos(key, amishi_id) do
    case get_by_key(key, amishi_id) do
      nil -> nil
      cotonoma ->
        if check_permission(cotonoma, amishi_id) do
          cotos =
            Coto 
            |> Coto.in_cotonoma(cotonoma.id)
            |> preload([:posted_in, :cotonoma])
            |> Repo.all
          {cotonoma, cotos}
        else
          nil
        end
    end
  end
end
