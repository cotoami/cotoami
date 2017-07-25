defmodule Cotoami.GraphServiceTest do
  use Cotoami.ModelCase
  import Cotoami.Helpers
  alias Cotoami.GraphService

  test "get or create a node" do
    # create a simple node
    uuid1 = "9108c2b8-87bb-4321-99ec-e5ce2e581702"
    node1 =
      GraphService.get_or_create_node(uuid1)
      |> and_then(fn(node) ->
        assert [] = node.labels
        assert %{"uuid" => ^uuid1} = node.properties
        node
      end)

    # create a node with labels and properties
    uuid2 = "71d1a0f1-d760-4b5a-a7e8-f975b44bb16"
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

    uuid1 = "094c861f-40a4-4a96-ac1c-cbeff666b9b9"
    %Bolt.Sips.Types.Node{id: node1_id} = GraphService.get_or_create_node(uuid1)

    uuid2 = "a67cad88-f4ea-4791-895f-a14838462bc6"
    %Bolt.Sips.Types.Node{id: node2_id} = GraphService.get_or_create_node(uuid2)

    # create a relationship
    assert %Bolt.Sips.Types.Relationship{
      id: relationship1_id,
      start: ^node1_id,
      end: ^node2_id,
      properties: %{},
      type: "HOGE"
    } = GraphService.get_or_create_relationship(uuid1, uuid2, "HOGE")

    # get the relationship
    assert %Bolt.Sips.Types.Relationship{id: ^relationship1_id} =
      GraphService.get_or_create_relationship(uuid1, uuid2, "HOGE")

    # create a relationship of another type
    %Bolt.Sips.Types.Relationship{id: relationship2_id} =
      GraphService.get_or_create_relationship(uuid1, uuid2, "HUGA")
    assert relationship1_id != relationship2_id
  end
end
