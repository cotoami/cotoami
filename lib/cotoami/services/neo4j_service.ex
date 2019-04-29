defmodule Cotoami.Neo4jService do
  @moduledoc """
  Provides basic functions for Neo4j graph database
  """

  require Logger
  alias Bolt.Sips.Types.Relationship

  @rel_prop_order "order"

  def rel_prop_order, do: @rel_prop_order

  def clear_database(conn) do
    Bolt.Sips.query!(conn, "MATCH (n) DETACH DELETE n")
  end

  def get_node(conn, uuid) do
    query = ~s"""
      MATCH (n { uuid: $uuid })
      RETURN n
    """

    case Bolt.Sips.query!(conn, query, %{uuid: uuid}) do
      [%{"n" => node}] -> node
      _ -> nil
    end
  end

  def get_or_create_node(conn, uuid, labels \\ [], props \\ %{}) do
    set_labels =
      if length(labels) > 0,
        do: ", n:" <> Enum.join(labels, ":"),
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

  def set_labels(conn, uuid, labels) do
    query = ~s"""
      MATCH (n { uuid: $uuid })
      SET n:#{Enum.join(labels, ":")}
      RETURN n
    """

    case Bolt.Sips.query!(conn, query, %{uuid: uuid}) do
      [%{"n" => node}] -> {:ok, node}
      _ -> {:error, "not-found"}
    end
  end

  def set_labels!(conn, uuid, labels) do
    {:ok, node} = set_labels(conn, uuid, labels)
    node
  end

  def replace_node_properties(conn, uuid, props) do
    query = ~s"""
      MATCH (n { uuid: $uuid })
      SET n = $props
      RETURN n
    """

    result =
      Bolt.Sips.query!(conn, query, %{
        uuid: uuid,
        props: Map.put(props, :uuid, uuid)
      })

    case result do
      [%{"n" => node}] -> {:ok, node}
      _ -> {:error, "not-found"}
    end
  end

  def replace_node_properties!(conn, uuid, props) do
    {:ok, node} = replace_node_properties(conn, uuid, props)
    node
  end

  def get_or_create_relationship(conn, source_uuid, target_uuid, type, props \\ %{}) do
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

  def get_relationship(conn, source_uuid, target_uuid, type) do
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

  def set_relationship_properties(conn, source_uuid, target_uuid, type, props) do
    query = ~s"""
      MATCH (source { uuid: $source_uuid })-[r:#{type}]->(target { uuid: $target_uuid })
      SET r += $props
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

  def reverse_relationship(conn, source_uuid, target_uuid, type) do
    target_rel = get_relationship(conn, source_uuid, target_uuid, type)
    reverse_rel = get_relationship(conn, target_uuid, source_uuid, type)

    case {target_rel, reverse_rel} do
      {nil, nil} ->
        nil

      {target_rel, nil} ->
        %Relationship{properties: props} = target_rel
        reverse_rel = get_or_create_relationship(conn, target_uuid, source_uuid, type, props)
        delete_relationship(conn, source_uuid, target_uuid, type)
        reverse_rel

      _ ->
        nil
    end
  end

  def delete_relationship(conn, source_uuid, target_uuid, type) do
    query = ~s"""
      MATCH (source { uuid: $source_uuid })-[r:#{type}]->(target { uuid: $target_uuid })
      DELETE r
    """

    result =
      Bolt.Sips.query!(conn, query, %{
        source_uuid: source_uuid,
        target_uuid: target_uuid
      })

    case result do
      %{stats: %{"relationships-deleted" => 1}, type: "w"} -> {:ok, nil}
      _ -> {:error, "error"}
    end
  end

  def get_ordered_relationships(conn, source_uuid, type) do
    query = ~s"""
      MATCH (source { uuid: $source_uuid })-[r:#{type}]->(target)
      RETURN r
      ORDER BY r.#{@rel_prop_order}
    """

    conn
    |> Bolt.Sips.query!(query, %{source_uuid: source_uuid})
    |> Enum.map(& &1["r"])
  end

  def get_or_create_ordered_relationship(conn, source_uuid, target_uuid, type, props \\ %{}) do
    next_order =
      case get_ordered_relationships(conn, source_uuid, type) do
        [] ->
          1

        rels ->
          case List.last(rels).properties[@rel_prop_order] do
            nil -> length(rels) + 1
            last_order -> last_order + 1
          end
      end

    get_or_create_relationship(
      conn,
      source_uuid,
      target_uuid,
      type,
      props |> Map.put(@rel_prop_order, next_order)
    )
  end

  def update_relationships_order(conn, source_uuid, target_uuids, type)
      when is_list(target_uuids) do
    query = ~s"""
      UNWIND $targets AS target
      WITH head(target) AS target_uuid, last(target) AS order
      MATCH (source { uuid: $source_uuid })-[r:#{type}]->(target { uuid: target_uuid })
      SET r.#{@rel_prop_order} = order
      RETURN r
    """

    conn
    |> Bolt.Sips.query!(query, %{
      source_uuid: source_uuid,
      targets:
        target_uuids
        |> Enum.with_index(1)
        |> Enum.map(fn {uuid, order} -> [uuid, order] end)
    })
    |> Enum.map(& &1["r"])
  end

  def delete_node_with_relationships(conn, uuid) do
    query = ~s"""
      MATCH (n { uuid: $uuid })
      DETACH DELETE n
    """

    case Bolt.Sips.query!(conn, query, %{uuid: uuid}) do
      %{stats: %{"nodes-deleted" => 1}, type: "w"} -> {:ok, nil}
      _ -> {:error, "error"}
    end
  end

  def get_paths(conn, start_uuid, end_uuid) do
    query = ~s"""
      MATCH path = ({ uuid: $start_uuid })-[*]->({ uuid: $end_uuid })
      RETURN path
    """

    Bolt.Sips.query!(conn, query, %{start_uuid: start_uuid, end_uuid: end_uuid})
  end
end
