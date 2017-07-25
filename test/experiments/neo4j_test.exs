defmodule Cotoami.Neo4jTest do
  use ExUnit.Case

  test "the truth" do
    assert 1 + 1 == 2
  end

  test "basic queries" do
    conn = Bolt.Sips.conn
    assert %{stats: %{"labels-added" => 1, "nodes-created" => 1, "properties-set" => 1}, type: "w"} =
      Bolt.Sips.query!(conn, "CREATE (a:Person {name:'Bob'})")
    assert [%{"name" => "Bob"}] =
      Bolt.Sips.query!(conn, "MATCH (a:Person {name: 'Bob'}) RETURN a.name AS name")
    assert %{stats: %{"nodes-deleted" => 1}, type: "w"} =
      Bolt.Sips.query!(conn, "MATCH (a:Person {name:'Bob'}) DELETE a")
  end

  test "get or create a node" do
    node_properties = %{name: "Charlie Sheen", age: 10}
    query = ~s"""
      MERGE (node:Person { name: $props.name })
      ON CREATE SET node=$props
      RETURN node
    """
    conn = Bolt.Sips.conn

    # Create a node
    [%{"node" => node}] = Bolt.Sips.query!(conn, query, %{"props" => node_properties})
    assert %Bolt.Sips.Types.Node{labels: ["Person"], properties: node_properties } = node

    # Get the node
    existing_node_id = node.id
    assert [
      %{"node" =>
        %Bolt.Sips.Types.Node{
          id: existing_node_id,
          labels: ["Person"],
          properties: node_properties
        }
      }
    ] = Bolt.Sips.query!(conn, query, %{"props" => node_properties})
  end

  test "merge against mutiple labels" do
    conn = Bolt.Sips.conn

    [%{"node" => node1}] =
      Bolt.Sips.query!(conn, "CREATE (node:Label1:Label2 { name: 'test' }) RETURN node")

    [%{"node" => node2}] =
      Bolt.Sips.query!(conn, "MERGE (node:Label1 { name: 'test' }) RETURN node")

    assert node1.id == node2.id
    assert ["Label1", "Label2"] = Enum.sort(node2.labels)
    assert %{"name" => "test"} = node2.properties
  end
end
