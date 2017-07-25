defmodule Cotoami.Neo4jService do
  require Logger

  def get_or_create_node(uuid, labels \\ [], props \\ %{})
  when is_binary(uuid) and is_list(labels) and is_map(props) do
    set_labels =
      if length(labels) > 0,
        do: ", n :" <> Enum.join(labels, ":"),
        else: ""
    query = ~s"""
      MERGE (n { uuid: $uuid })
      ON CREATE SET n = $props #{set_labels}
      RETURN n
    """
    [%{"n" => node}] =
      Bolt.Sips.query!(Bolt.Sips.conn, query, %{
        uuid: uuid,
        props: Map.put(props, :uuid, uuid)
      })
    node
  end

  def get_or_create_relationship(source_uuid, target_uuid, type)
  when is_binary(source_uuid) and is_binary(target_uuid) and is_binary(type) do
    query = ~s"""
      MATCH (source { uuid: $source_uuid }),(target { uuid: $target_uuid })
      MERGE (source)-[r:#{type}]->(target)
      RETURN r
    """
    result =
      Bolt.Sips.query!(Bolt.Sips.conn, query, %{
        source_uuid: source_uuid,
        target_uuid: target_uuid
      })
    case result do
      [%{"r" => relationship}] -> relationship
      _ -> nil
    end
  end

  def get_relationship(source_uuid, target_uuid, type)
  when is_binary(source_uuid) and is_binary(target_uuid) and is_binary(type) do
    query = ~s"""
      MATCH (source { uuid: $source_uuid })-[r:#{type}]->(target { uuid: $target_uuid })
      RETURN r
    """
    result =
      Bolt.Sips.query!(Bolt.Sips.conn, query, %{
        source_uuid: source_uuid,
        target_uuid: target_uuid
      })
    case result do
      [%{"r" => relationship}] -> relationship
      _ -> nil
    end
  end

  def delete_relationship(source_uuid, target_uuid, type)
  when is_binary(source_uuid) and is_binary(target_uuid) and is_binary(type) do
    query = ~s"""
      MATCH (source { uuid: $source_uuid })-[r:#{type}]->(target { uuid: $target_uuid })
      DELETE r
    """
    Bolt.Sips.query!(Bolt.Sips.conn, query, %{
      source_uuid: source_uuid,
      target_uuid: target_uuid
    })
  end
end
