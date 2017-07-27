defmodule Cotoami.CotoGraphService do
  require Logger
  import Cotoami.Helpers
  alias Cotoami.Coto
  alias Cotoami.Amishi
  alias Cotoami.Cotonoma
  alias Cotoami.Neo4jService

  @label_amishi "Amishi"
  @label_coto "Coto"
  @label_cotonoma "Cotonoma"

  @rel_type_has_a "HAS_A"

  def pin(%Coto{} = coto, %Amishi{} = amishi) do
    Bolt.Sips.conn
    |> register_amishi(amishi)
    |> register_coto(coto)
    |> Neo4jService.get_or_create_ordered_relationship!(
      amishi.id, coto.id, @rel_type_has_a, common_rel_props(amishi.id))
  end
  def pin(%Coto{} = coto, %Cotonoma{} = cotonoma, %Amishi{} = amishi) do
    Bolt.Sips.conn
    |> register_amishi(amishi)
    |> register_coto(coto)
    |> register_cotonoma(cotonoma)
    |> Neo4jService.get_or_create_ordered_relationship!(
      cotonoma.id, coto.id, @rel_type_has_a, common_rel_props(amishi.id))
  end

  def unpin(%Coto{id: coto_id}, %Amishi{id: amishi_id}) do
    Bolt.Sips.conn
    |> Neo4jService.delete_relationship!(amishi_id, coto_id, @rel_type_has_a)
  end
  def unpin(%Coto{id: coto_id}, %Cotonoma{id: cotonoma_id}) do
    Bolt.Sips.conn
    |> Neo4jService.delete_relationship!(cotonoma_id, coto_id, @rel_type_has_a)
  end

  defp register_amishi(conn, %Amishi{id: amishi_id}) do
    Neo4jService.get_or_create_node!(conn, amishi_id, [@label_amishi])
    conn
  end

  defp register_coto(conn, coto) do
    labels = if coto.as_cotonoma, do: [@label_coto, @label_cotonoma], else: [@label_coto]
    props = %{
      content: coto.content,
      amishi_id: coto.amishi_id,
      cotonoma_key: if coto.as_cotonoma, do: coto.cotonoma.key, else: nil,
      posted_in: coto.posted_in_id,
      inserted_at: coto.inserted_at |> DateTime.to_unix(:millisecond),
      updated_at: coto.updated_at |> DateTime.to_unix(:millisecond)
    } |> drop_nil
    Neo4jService.get_or_create_node!(conn, coto.id, labels, props)
    conn
  end

  defp register_cotonoma(conn, cotonoma) do
    labels = [@label_coto, @label_cotonoma]
    props = %{
      content: cotonoma.name,
      amishi_id: cotonoma.coto.amishi_id,
      cotonoma_key: cotonoma.key,
      posted_in: cotonoma.coto.posted_in_id,
      inserted_at: cotonoma.coto.inserted_at |> DateTime.to_unix(:millisecond),
      updated_at: cotonoma.updated_at |> DateTime.to_unix(:millisecond)
    } |> drop_nil
    Neo4jService.get_or_create_node!(conn, cotonoma.coto.id, labels, props)
    conn
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
