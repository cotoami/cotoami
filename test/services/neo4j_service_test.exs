defmodule Cotoami.Neo4jServiceTest do
  use ExUnit.Case
  alias Cotoami.Neo4jService
  alias Bolt.Sips.Types.Node
  alias Bolt.Sips.Types.Relationship

  setup do
    %{conn: Bolt.Sips.conn}
  end

  describe "a basic node" do
    setup %{conn: conn} do
      uuid = UUID.uuid4()
      node = Neo4jService.get_or_create_node!(conn, uuid)
      %{uuid: uuid, node: node}
    end

    test "create", %{uuid: uuid, node: node} do
      assert [] = node.labels
      assert %{"uuid" => ^uuid} = node.properties
    end

    test "get with uuid", %{conn: conn, uuid: uuid, node: node} do
      existing_node_id = node.id
      assert %Node{
        id: ^existing_node_id,
        labels: [],
        properties:  %{"uuid" => ^uuid}
      } = Neo4jService.get_or_create_node!(conn, uuid)
    end
  end

  describe "a node with labels and properties" do
    setup %{conn: conn} do
      uuid = UUID.uuid4()
      labels = ["A", "B"]
      props = %{a: "hello", b: 1}
      node = Neo4jService.get_or_create_node!(conn, uuid, labels, props)
      %{uuid: uuid, node: node, labels: labels, props: props}
    end

    test "create", %{uuid: uuid, node: node, labels: labels} do
      assert ^labels = Enum.sort(node.labels)
      assert %{"a" => "hello", "b" => 1, "uuid" => ^uuid} = node.properties
    end

    test "get with uuid", %{conn: conn, uuid: uuid, node: node, labels: labels} do
      result = Neo4jService.get_or_create_node!(conn, uuid)
      assert node.id == result.id
      assert ^labels = Enum.sort(result.labels)
      assert %{"a" => "hello", "b" => 1, "uuid" => ^uuid} = result.properties
    end

    test "get with uuid (labels and props will be ignored)",
        %{conn: conn, uuid: uuid, node: node, labels: labels} do
      result = Neo4jService.get_or_create_node!(conn, uuid, ["C"], %{c: "bye"})
      assert node.id == result.id
      assert ^labels = Enum.sort(result.labels)
    end
  end

  describe "a relationship" do
    setup %{conn: conn} do
      uuid1 = UUID.uuid4()
      %Node{id: node1_id} = Neo4jService.get_or_create_node!(conn, uuid1)
      uuid2 = UUID.uuid4()
      %Node{id: node2_id} = Neo4jService.get_or_create_node!(conn, uuid2)
      rel = Neo4jService.get_or_create_relationship!(conn, uuid1, uuid2, "A")
      %{uuid1: uuid1, node1_id: node1_id, uuid2: uuid2, node2_id: node2_id, rel: rel}
    end

    test "get nil when the nodes are not found", %{conn: conn} do
      assert nil ==
        Neo4jService.get_or_create_relationship!(conn, "no-such-uuid", "no-such-uuid", "RELTYPE")
    end

    test "create", %{node1_id: node1_id, node2_id: node2_id, rel: rel} do
      assert node1_id == rel.start
      assert node2_id == rel.end
      assert %{} == rel.properties
      assert "A" == rel.type
    end

    test "get", %{conn: conn, uuid1: uuid1, uuid2: uuid2, rel: rel} do
      relationship_id = rel.id
      assert %Relationship{id: ^relationship_id} =
        Neo4jService.get_or_create_relationship!(conn, uuid1, uuid2, "A")
      assert %Relationship{id: ^relationship_id} =
        Neo4jService.get_relationship!(conn, uuid1, uuid2, "A")
    end

    test "create a relationship of another type", %{conn: conn, uuid1: uuid1, uuid2: uuid2, rel: rel} do
      %Relationship{id: relationship_id} =
        Neo4jService.get_or_create_relationship!(conn, uuid1, uuid2, "B")
      assert rel.id != relationship_id
    end

    test "get an non-existing relationship", %{conn: conn, uuid1: uuid1, uuid2: uuid2} do
      assert nil == Neo4jService.get_relationship!(conn, uuid1, uuid2, "C")
    end

    test "delete", %{conn: conn, uuid1: uuid1, uuid2: uuid2} do
      assert %{stats: %{"relationships-deleted" => 1}, type: "w"} =
        Neo4jService.delete_relationship!(conn, uuid1, uuid2, "A")
      assert nil == Neo4jService.get_relationship!(conn, uuid1, uuid2, "A")
    end
  end

  describe "a relationship with properties" do
    setup %{conn: conn} do
      uuid1 = UUID.uuid4()
      %Node{id: node1_id} = Neo4jService.get_or_create_node!(conn, uuid1)
      uuid2 = UUID.uuid4()
      %Node{id: node2_id} = Neo4jService.get_or_create_node!(conn, uuid2)
      rel = Neo4jService.get_or_create_relationship!(conn, uuid1, uuid2, "A", %{a: "hello", b: 1})
      %{uuid1: uuid1, node1_id: node1_id, uuid2: uuid2, node2_id: node2_id, rel: rel}
    end

    test "create", %{node1_id: node1_id, node2_id: node2_id, rel: rel} do
      assert node1_id == rel.start
      assert node2_id == rel.end
      assert %{"a" => "hello", "b" => 1} == rel.properties
      assert "A" == rel.type
    end
  end

  describe "ordered relationships" do
    setup %{conn: conn} do
      uuid1 = UUID.uuid4()
      Neo4jService.get_or_create_node!(conn, uuid1)
      uuid2 = UUID.uuid4()
      Neo4jService.get_or_create_node!(conn, uuid2)
      uuid3 = UUID.uuid4()
      Neo4jService.get_or_create_node!(conn, uuid3)

      rel1 = Neo4jService.get_or_create_ordered_relationship!(conn, uuid1, uuid2, "A")
      rel2 = Neo4jService.get_or_create_ordered_relationship!(conn, uuid1, uuid3, "A")
      %{uuid1: uuid1, uuid2: uuid2, uuid3: uuid3, rel1: rel1, rel2: rel2}
    end

    test "create", %{rel1: rel1, rel2: rel2} do
      assert %Relationship{properties: %{"order" => 1}} = rel1
      assert %Relationship{properties: %{"order" => 2}} = rel2
    end

    test "get", %{conn: conn, uuid1: uuid1, rel1: rel1, rel2: rel2} do
      {rel1_id, rel2_id} = {rel1.id, rel2.id}
      assert [
        %Relationship{id: ^rel1_id, properties: %{"order" => 1}},
        %Relationship{id: ^rel2_id, properties: %{"order" => 2}}
      ] = Neo4jService.get_ordered_relationships!(conn, uuid1, "A")
    end
  end
end
