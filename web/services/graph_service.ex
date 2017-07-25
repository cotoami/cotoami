defmodule Cotoami.GraphService do
  require Logger
  alias Cotoami.Coto
  alias Cotoami.Amishi
  alias Cotoami.Cotonoma

  def pin(
    %Coto{} = coto,
    %Amishi{id: amishi_id},
    %Cotonoma{id: cotonoma_id, coto: %Coto{id: cotonoma_coto_id}} \\ nil
  ) do

  end

  def get_or_create_node(uuid, labels \\ [], props \\ %{})
  when is_binary(uuid) and is_list(labels) and is_map(props) do
    query = ~s"""
      MERGE (node#{labels_in_query(labels)} { uuid: $uuid })
      ON CREATE SET node=$props
      RETURN node
    """
    [%{"node" => node}] =
      Bolt.Sips.query!(Bolt.Sips.conn, query, %{
        uuid: uuid,
        props: Map.put(props, :uuid, uuid)
      })
    node
  end

  def create_relationship(source_uuid, target_uuid, type)
  when is_binary(source_uuid) and is_binary(target_uuid) and is_binary(type) do
    query = ~s"""
      MATCH (source { uuid: $source_uuid }),(target { uuid: $target_uuid })
      MERGE (source)-[relationship:#{type}]->(target)
      RETURN relationship
    """
    result =
      Bolt.Sips.query!(Bolt.Sips.conn, query, %{
        source_uuid: source_uuid,
        target_uuid: target_uuid
      })
    case result do
      [%{"relationship" => relationship}] -> relationship
      _ -> nil
    end
  end

  defp labels_in_query(labels) do
    if length(labels) > 0, do: ":" <> Enum.join(labels, ":"), else: ""
  end
end
