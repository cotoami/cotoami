defmodule Cotoami.Neo4jService do
  @moduledoc """
  Provides basic functions for Neo4j graph database
  """

  require Logger

  @rel_prop_order "order"

  def rel_prop_order, do: @rel_prop_order

  def get_node!(conn, uuid) do
    query = ~s"""
      MATCH (n { uuid: $uuid })
      RETURN n
    """
    case Bolt.Sips.query!(conn, query, %{uuid: uuid}) do
      [%{"n" => node}] -> node
      _ -> nil
    end
  end

  def get_or_create_node!(conn, uuid, labels \\ [], props \\ %{}) do
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
      Bolt.Sips.query!(conn, query, %{
        uuid: uuid,
        props: Map.put(props, :uuid, uuid)
      })
    node
  end

  def get_or_create_relationship!(conn, source_uuid, target_uuid, type, props \\ %{}) do
    query = ~s"""
      MATCH (source { uuid: $source_uuid }),(target { uuid: $target_uuid })
      MERGE (source)-[r:#{type}]->(target)
      ON CREATE SET r = $props
      RETURN r
    """
    result =
      Bolt.Sips.query!(conn, query, %{
        source_uuid: source_uuid,
        target_uuid: target_uuid,
        props: props
      })
    case result do
      [%{"r" => relationship}] -> relationship
      _ -> nil
    end
  end

  def get_relationship!(conn, source_uuid, target_uuid, type) do
    query = ~s"""
      MATCH (source { uuid: $source_uuid })-[r:#{type}]->(target { uuid: $target_uuid })
      RETURN r
    """
    result =
      Bolt.Sips.query!(conn, query, %{
        source_uuid: source_uuid,
        target_uuid: target_uuid
      })
    case result do
      [%{"r" => relationship}] -> relationship
      _ -> nil
    end
  end

  def delete_relationship!(conn, source_uuid, target_uuid, type) do
    query = ~s"""
      MATCH (source { uuid: $source_uuid })-[r:#{type}]->(target { uuid: $target_uuid })
      DELETE r
    """
    Bolt.Sips.query!(conn, query, %{
      source_uuid: source_uuid,
      target_uuid: target_uuid
    })
  end

  def get_ordered_relationships!(conn, source_uuid, type) do
    query = ~s"""
      MATCH (source { uuid: $source_uuid })-[r:#{type}]->(target)
      RETURN r
      ORDER BY r.#{@rel_prop_order}
    """
    conn
    |> Bolt.Sips.query!(query, %{source_uuid: source_uuid})
    |> Enum.map(&(&1["r"]))
  end

  def get_or_create_ordered_relationship!(conn, source_uuid, target_uuid, type, props \\ %{}) do
    next_order =
      case get_ordered_relationships!(conn, source_uuid, type) do
        [] -> 1
        rels ->
          case List.last(rels).properties[@rel_prop_order] do
            nil -> length(rels) + 1
            last_order -> last_order + 1
          end
      end
    get_or_create_relationship!(conn, source_uuid, target_uuid, type,
      props |> Map.put(@rel_prop_order, next_order))
  end

  def delete_node_with_relationships!(conn, uuid) do
    query = ~s"""
      MATCH (n { uuid: $uuid })
      DETACH DELETE n
    """
    Bolt.Sips.query!(conn, query, %{uuid: uuid})
  end

  def get_paths!(conn, start_uuid, end_uuid) do
    query = ~s"""
      MATCH path = ({ uuid: $start_uuid })-[*]->({ uuid: $end_uuid })
      RETURN path
    """
    Bolt.Sips.query!(conn, query, %{start_uuid: start_uuid, end_uuid: end_uuid})
  end
end
