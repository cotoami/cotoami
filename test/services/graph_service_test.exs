defmodule Cotoami.GraphServiceTest do
  use ExUnit.Case
  import Cotoami.Helpers
  alias Cotoami.GraphService
  alias Bolt.Sips.Types.Node
  alias Bolt.Sips.Types.Relationship

  test "get or create a node" do
    # create a simple node
    uuid1 = UUID.uuid4()
    node1 =
      GraphService.get_or_create_node(uuid1)
      |> and_then(fn(node) ->
        assert [] = node.labels
        assert %{"uuid" => ^uuid1} = node.properties
        node
      end)

    # create a node with labels and properties
    uuid2 = UUID.uuid4()
    labels = ["A", "B"]
    props = %{a: "hello", b: 1}
    node2 =
      GraphService.get_or_create_node(uuid2, labels, props)
      |> and_then(fn(node) ->
        assert ^labels = Enum.sort(node.labels)
        assert %{"a" => "hello", "b" => 1, "uuid" => ^uuid2} = node.properties
        node
      end)

    # get node1 and node2 with uuid
    GraphService.get_or_create_node(uuid1)
    |> and_then(fn(node) ->
      assert node1.id == node.id
      assert [] = node.labels
      assert %{"uuid" => ^uuid1} = node.properties
    end)
    GraphService.get_or_create_node(uuid2)
    |> and_then(fn(node) ->
      assert node2.id == node.id
      assert ^labels = Enum.sort(node.labels)
      assert %{"a" => "hello", "b" => 1, "uuid" => ^uuid2} = node.properties
    end)

    # get node2 with one label
    GraphService.get_or_create_node(uuid2, ["B"])
    |> and_then(fn(node) ->
      assert node2.id == node.id
      assert ^labels = Enum.sort(node.labels)
    end)

    # create a new node when the labels does not match
    GraphService.get_or_create_node(uuid2, ["C"])
    |> and_then(fn(node) ->
      assert node2.id != node.id
    end)

    # properties will be ignored if the node already exists
    GraphService.get_or_create_node(uuid2, ["A"], %{c: "bye"})
    |> and_then(fn(node) ->
      assert node2.id == node.id
      assert %{"a" => "hello", "b" => 1, "uuid" => ^uuid2} = node.properties
    end)
  end

  test "get or create a relationship" do
    assert nil ==
      GraphService.get_or_create_relationship("no-such-uuid", "no-such-uuid", "RELTYPE")

    uuid1 = UUID.uuid4()
    %Node{id: node1_id} = GraphService.get_or_create_node(uuid1)

    uuid2 = UUID.uuid4()
    %Node{id: node2_id} = GraphService.get_or_create_node(uuid2)

    # create a relationship
    assert %Relationship{
      id: relationship1_id,
      start: ^node1_id,
      end: ^node2_id,
      properties: %{},
      type: "A"
    } = GraphService.get_or_create_relationship(uuid1, uuid2, "A")

    # get the relationship
    assert %Relationship{id: ^relationship1_id} =
      GraphService.get_or_create_relationship(uuid1, uuid2, "A")
    assert %Relationship{id: ^relationship1_id} =
      GraphService.get_relationship(uuid1, uuid2, "A")

    # create a relationship of another type
    %Relationship{id: relationship2_id} =
      GraphService.get_or_create_relationship(uuid1, uuid2, "B")
    assert relationship1_id != relationship2_id

    # try to get an non-existing relationship
    assert nil == GraphService.get_relationship(uuid1, uuid2, "C")
  end

  test "delete a relationship" do
    uuid1 = UUID.uuid4()
    %Node{id: node1_id} = GraphService.get_or_create_node(uuid1)

    uuid2 = UUID.uuid4()
    %Node{id: node2_id} = GraphService.get_or_create_node(uuid2)

    %Relationship{id: relationship_id} =
      GraphService.get_or_create_relationship(uuid1, uuid2, "A")

    assert %Relationship{id: ^relationship_id} =
      GraphService.get_relationship(uuid1, uuid2, "A")

    IO.puts inspect GraphService.delete_relationship(uuid1, uuid2, "A")

    assert nil == GraphService.get_relationship(uuid1, uuid2, "A")
  end
end
