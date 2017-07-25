defmodule Cotoami.Neo4jServiceTest do
  use ExUnit.Case
  import Cotoami.Helpers
  alias Cotoami.Neo4jService
  alias Bolt.Sips.Types.Node
  alias Bolt.Sips.Types.Relationship

  describe "a basic node" do
    setup do
      uuid = UUID.uuid4()
      node = Neo4jService.get_or_create_node(uuid)
      %{uuid: uuid, node: node}
    end

    test "create", %{uuid: uuid, node: node} do
      assert [] = node.labels
      assert %{"uuid" => ^uuid} = node.properties
    end

    test "get with uuid", %{uuid: uuid, node: node} do
      existing_node_id = node.id
      assert %Node{
        id: ^existing_node_id,
        labels: [],
        properties:  %{"uuid" => ^uuid}
      } = Neo4jService.get_or_create_node(uuid)
    end
  end

  describe "a node with labels and properties" do
    setup do
      uuid = UUID.uuid4()
      labels = ["A", "B"]
      props = %{a: "hello", b: 1}
      node = Neo4jService.get_or_create_node(uuid, labels, props)
      %{uuid: uuid, node: node, labels: labels, props: props}
    end

    test "create",
        %{uuid: uuid, node: node, labels: labels, props: props} do
      assert ^labels = Enum.sort(node.labels)
      assert %{"a" => "hello", "b" => 1, "uuid" => ^uuid} = node.properties
    end

    test "get with uuid",
        %{uuid: uuid, node: node, labels: labels, props: props} do
      result = Neo4jService.get_or_create_node(uuid)
      assert node.id == result.id
      assert ^labels = Enum.sort(result.labels)
      assert %{"a" => "hello", "b" => 1, "uuid" => ^uuid} = result.properties
    end

    test "get with uuid and one label",
        %{uuid: uuid, node: node, labels: labels, props: props} do
      result = Neo4jService.get_or_create_node(uuid, ["B"])
      assert node.id == result.id
      assert ^labels = Enum.sort(result.labels)
    end

    test "only uuid decides which node to select",
        %{uuid: uuid, node: node, labels: labels, props: props} do
      result = Neo4jService.get_or_create_node(uuid, ["C"], %{c: "bye"})
      assert node.id == result.id
      assert ^labels = Enum.sort(result.labels)
    end
  end

  describe "a relationship" do
    setup do
      uuid1 = UUID.uuid4()
      %Node{id: node1_id} = Neo4jService.get_or_create_node(uuid1)
      uuid2 = UUID.uuid4()
      %Node{id: node2_id} = Neo4jService.get_or_create_node(uuid2)
      rel = Neo4jService.get_or_create_relationship(uuid1, uuid2, "A")
      %{uuid1: uuid1, node1_id: node1_id, uuid2: uuid2, node2_id: node2_id, rel: rel}
    end

    test "get nil when the nodes are not found", _params do
      assert nil ==
        Neo4jService.get_or_create_relationship("no-such-uuid", "no-such-uuid", "RELTYPE")
    end

    test "create", %{node1_id: node1_id, node2_id: node2_id, rel: rel} do
      assert node1_id == rel.start
      assert node2_id == rel.end
      assert %{} == rel.properties
      assert "A" == rel.type
    end

    test "get", %{uuid1: uuid1, uuid2: uuid2, rel: rel} do
      relationship_id = rel.id
      assert %Relationship{id: ^relationship_id} =
        Neo4jService.get_or_create_relationship(uuid1, uuid2, "A")
      assert %Relationship{id: ^relationship_id} =
        Neo4jService.get_relationship(uuid1, uuid2, "A")
    end

    test "create a relationship of another type", %{uuid1: uuid1, uuid2: uuid2, rel: rel} do
      %Relationship{id: relationship_id} =
        Neo4jService.get_or_create_relationship(uuid1, uuid2, "B")
      assert rel.id != relationship_id
    end

    test "get an non-existing relationship", %{uuid1: uuid1, uuid2: uuid2} do
      assert nil == Neo4jService.get_relationship(uuid1, uuid2, "C")
    end

    test "delete", %{uuid1: uuid1, uuid2: uuid2, rel: rel} do
      assert %{stats: %{"relationships-deleted" => 1}, type: "w"} =
        Neo4jService.delete_relationship(uuid1, uuid2, "A")
      assert nil == Neo4jService.get_relationship(uuid1, uuid2, "A")
    end
  end
end
