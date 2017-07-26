defmodule Cotoami.CotoGraphService do
  require Logger
  alias Cotoami.Coto
  alias Cotoami.Amishi
  alias Cotoami.Cotonoma
  alias Cotoami.Neo4jService

  @label_coto "Coto"
  @label_amishi "Amishi"

  @rel_type_has "HAS"

  def pin(
    %Coto{id: coto_id} = coto,
    %Amishi{id: amishi_id} = amishi,
    %Cotonoma{} = cotonoma \\ nil
  ) do
    register_coto(coto)
    register_amishi(amishi)
    case cotonoma do
      nil ->
        # calculate order
        Neo4jService.get_or_create_relationship!(amishi_id, coto_id, @rel_type_has)
      cotonoma ->
        "bar"
    end
  end

  defp register_coto(%Coto{id: coto_id}) do
    Neo4jService.get_or_create_node(coto_id, [@label_coto])
  end

  defp register_amishi(%Amishi{id: amishi_id}) do
    Neo4jService.get_or_create_node(amishi_id, [@label_amishi])
  end

  defp common_rel_props(amishi_id) do
    %{
      created_by: amishi_id,
      created_at: System.system_time(:millisecond)
    }
  end
  defp common_rel_props(amishi_id, cotonoma_id) do
    common_rel_props(amishi_id)
    |> Map.put(:created_in, cotonoma_id)
  end
end
