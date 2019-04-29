defmodule Cotoami.Neo4jServiceTest do
  use ExUnit.Case
  import ShorterMaps
  alias Cotoami.Neo4jService
  alias Bolt.Sips.Types.Node
  alias Bolt.Sips.Types.Relationship

  setup do
    %{conn: Bolt.Sips.conn()}
  end

  describe "when there is a node" do
    setup ~M{conn} do
      uuid = UUID.uuid4()
      node = Neo4jService.get_or_create_node(conn, uuid)
      ~M{uuid, node}
    end

    test "it should contain empty labels and the uuid in its properties", ~M{uuid, node} do
      assert [] = node.labels
      assert %{"uuid" => ^uuid} = node.properties
    end

    test "it can be gotten by uuid", ~M{conn, uuid, node} do
      existing_node_id = node.id

      assert %Node{
               id: ^existing_node_id,
               labels: [],
               properties: %{"uuid" => ^uuid}
             } = Neo4jService.get_node(conn, uuid)

      assert %Node{
               id: ^existing_node_id,
               labels: [],
               properties: %{"uuid" => ^uuid}
             } = Neo4jService.get_or_create_node(conn, uuid)
    end

    test "it can be deleted", ~M{conn, uuid} do
      assert {:ok, nil} = Neo4jService.delete_node_with_relationships(conn, uuid)
      assert nil == Neo4jService.get_node(conn, uuid)
    end

    test "adding labels", ~M{conn, uuid} do
      %Node{labels: labels} = Neo4jService.set_labels!(conn, uuid, ["Foo", "Bar"])
      assert Enum.sort(labels) == ["Bar", "Foo"]
    end
  end

  describe "when there is a node with labels and properties" do
    setup ~M{conn} do
      uuid = UUID.uuid4()
      labels = ["A", "B"]
      props = %{a: "hello", b: 1}
      node = Neo4jService.get_or_create_node(conn, uuid, labels, props)
      ~M{uuid, node, labels, props}
    end

    test "it should contain expected labels and properties", ~M{uuid, node, labels} do
      assert ^labels = Enum.sort(node.labels)
      assert %{"a" => "hello", "b" => 1, "uuid" => ^uuid} = node.properties
    end

    test "it can be gotten by uuid", ~M{conn, uuid, node, labels} do
      result = Neo4jService.get_or_create_node(conn, uuid)
      assert node.id == result.id
      assert ^labels = Enum.sort(result.labels)
      assert %{"a" => "hello", "b" => 1, "uuid" => ^uuid} = result.properties
    end

    test "it can be gotten by uuid (labels and props will be ignored)",
         ~M{conn, uuid, node, labels} do
      result = Neo4jService.get_or_create_node(conn, uuid, ["C"], %{c: "bye"})
      assert node.id == result.id
      assert ^labels = Enum.sort(result.labels)
    end

    test "the properties can be replaced with new ones", ~M{conn, uuid} do
      {:ok, node} = Neo4jService.replace_node_properties(conn, uuid, %{a: "updated"})
      assert %{"a" => "updated", "uuid" => ^uuid} = node.properties
      assert %{"a" => "updated", "uuid" => ^uuid} = Neo4jService.get_node(conn, uuid).properties
    end

    test "the properties can't be replaced by an invalid uuid", ~M{conn} do
      assert {:error, "not-found"} =
               Neo4jService.replace_node_properties(conn, "no-such-uuid", %{})
    end
  end

  describe "when there is a relationship" do
    setup ~M{conn} do
      uuid1 = UUID.uuid4()
      %Node{id: node1_id} = Neo4jService.get_or_create_node(conn, uuid1)
      uuid2 = UUID.uuid4()
      %Node{id: node2_id} = Neo4jService.get_or_create_node(conn, uuid2)
      rel = Neo4jService.get_or_create_relationship(conn, uuid1, uuid2, "A")
      ~M{uuid1, node1_id, uuid2, node2_id, rel}
    end

    test "a relation can't be created or gotten by a nonexistent uuid", ~M{conn} do
      assert nil ==
               Neo4jService.get_or_create_relationship(
                 conn,
                 "no-such-uuid",
                 "no-such-uuid",
                 "RELTYPE"
               )
    end

    test "it should have correct attributes", ~M{node1_id, node2_id, rel} do
      assert node1_id == rel.start
      assert node2_id == rel.end
      assert %{} == rel.properties
      assert "A" == rel.type
    end

    test "it can be gotten by start and end uuids", ~M{conn, uuid1, uuid2, rel} do
      relationship_id = rel.id

      assert %Relationship{id: ^relationship_id} =
               Neo4jService.get_or_create_relationship(conn, uuid1, uuid2, "A")

      assert %Relationship{id: ^relationship_id} =
               Neo4jService.get_relationship(conn, uuid1, uuid2, "A")
    end

    test "a same relationship of another type can be created", ~M{conn, uuid1, uuid2, rel} do
      %Relationship{id: relationship_id} =
        Neo4jService.get_or_create_relationship(conn, uuid1, uuid2, "B")

      assert rel.id != relationship_id
    end

    test "specifying a nonexistent type should return nil", ~M{conn, uuid1, uuid2} do
      assert nil == Neo4jService.get_relationship(conn, uuid1, uuid2, "C")
    end

    test "can be deleted", ~M{conn, uuid1, uuid2} do
      assert {:ok, nil} = Neo4jService.delete_relationship(conn, uuid1, uuid2, "A")
      assert nil == Neo4jService.get_relationship(conn, uuid1, uuid2, "A")
    end
  end

  describe "when there is a relationship with properties" do
    setup ~M{conn} do
      uuid1 = UUID.uuid4()
      %Node{id: node1_id} = Neo4jService.get_or_create_node(conn, uuid1)
      uuid2 = UUID.uuid4()
      %Node{id: node2_id} = Neo4jService.get_or_create_node(conn, uuid2)
      Neo4jService.get_or_create_relationship(conn, uuid1, uuid2, "A", %{a: "hello", b: 1})
      ~M{uuid1, uuid2, node1_id, node2_id}
    end

    test "it should have correct attributes and properties",
         ~M{conn, uuid1, uuid2, node1_id, node2_id} do
      rel = Neo4jService.get_relationship(conn, uuid1, uuid2, "A")
      assert rel.start == node1_id
      assert rel.end == node2_id
      assert rel.properties == %{"a" => "hello", "b" => 1}
      assert rel.type == "A"
    end

    test "its properties can be updated", ~M{conn, uuid1, uuid2} do
      Neo4jService.set_relationship_properties(conn, uuid1, uuid2, "A", %{b: 2, c: "bye"})

      rel = Neo4jService.get_relationship(conn, uuid1, uuid2, "A")
      assert rel.properties == %{"a" => "hello", "b" => 2, "c" => "bye"}
    end

    test "it can be reversed", ~M{conn, uuid1, uuid2, node1_id, node2_id} do
      Neo4jService.reverse_relationship(conn, uuid1, uuid2, "A")

      assert Neo4jService.get_relationship(conn, uuid1, uuid2, "A") == nil

      reverse_rel = Neo4jService.get_relationship(conn, uuid2, uuid1, "A")
      assert reverse_rel.start == node2_id
      assert reverse_rel.end == node1_id
      assert reverse_rel.properties == %{"a" => "hello", "b" => 1}
      assert reverse_rel.type == "A"
    end
  end

  describe "when there are ordered relationships" do
    setup ~M{conn} do
      uuid1 = UUID.uuid4()
      Neo4jService.get_or_create_node(conn, uuid1)
      uuid2 = UUID.uuid4()
      Neo4jService.get_or_create_node(conn, uuid2)
      uuid3 = UUID.uuid4()
      Neo4jService.get_or_create_node(conn, uuid3)

      rel1 = Neo4jService.get_or_create_ordered_relationship(conn, uuid1, uuid2, "A")
      rel2 = Neo4jService.get_or_create_ordered_relationship(conn, uuid1, uuid3, "A")
      ~M{uuid1, uuid2, uuid3, rel1, rel2}
    end

    test "they should have correct order numbers", ~M{rel1, rel2} do
      assert %Relationship{properties: %{"order" => 1}} = rel1
      assert %Relationship{properties: %{"order" => 2}} = rel2
    end

    test "they can be gotten in the expected order", ~M{conn, uuid1, rel1, rel2} do
      {rel1_id, rel2_id} = {rel1.id, rel2.id}

      assert [
               %Relationship{id: ^rel1_id, properties: %{"order" => 1}},
               %Relationship{id: ^rel2_id, properties: %{"order" => 2}}
             ] = Neo4jService.get_ordered_relationships(conn, uuid1, "A")
    end

    test "they can be reordered", ~M{conn, uuid1, uuid2, uuid3, rel1, rel2} do
      Neo4jService.update_relationships_order(conn, uuid1, [uuid3, uuid2], "A")
      {rel1_id, rel2_id} = {rel1.id, rel2.id}

      assert [
               %Relationship{id: ^rel2_id, properties: %{"order" => 1}},
               %Relationship{id: ^rel1_id, properties: %{"order" => 2}}
             ] = Neo4jService.get_ordered_relationships(conn, uuid1, "A")
    end
  end

  describe "when there is a graph: A -> B -> C, and D as an orphan" do
    setup ~M{conn} do
      [uuid_a, uuid_b, uuid_c, uuid_d] =
        1..4 |> Enum.to_list()
        |> Enum.map(fn _ ->
          uuid = UUID.uuid4()
          Neo4jService.get_or_create_node(conn, uuid)
          uuid
        end)

      rel_a_b = Neo4jService.get_or_create_ordered_relationship(conn, uuid_a, uuid_b, "A")
      rel_b_c = Neo4jService.get_or_create_ordered_relationship(conn, uuid_b, uuid_c, "A")
      ~M{uuid_a, uuid_b, uuid_c, uuid_d, rel_a_b, rel_b_c}
    end

    test "the paths from A to B can be gotten", ~M{conn, uuid_a, uuid_b, rel_a_b} do
      rel_a_b_id = rel_a_b.id

      assert [
               %{
                 "path" => %Bolt.Sips.Types.Path{
                   nodes: [
                     %Bolt.Sips.Types.Node{properties: %{"uuid" => ^uuid_a}},
                     %Bolt.Sips.Types.Node{properties: %{"uuid" => ^uuid_b}}
                   ],
                   relationships: [%Bolt.Sips.Types.UnboundRelationship{id: ^rel_a_b_id}]
                 }
               }
             ] = Neo4jService.get_paths(conn, uuid_a, uuid_b)
    end

    test "the paths from A to C can be gotten",
         ~M{conn, uuid_a, uuid_b, uuid_c, rel_a_b, rel_b_c} do
      {rel_a_b_id, rel_b_c_id} = {rel_a_b.id, rel_b_c.id}

      assert [
               %{
                 "path" => %Bolt.Sips.Types.Path{
                   nodes: [
                     %Bolt.Sips.Types.Node{properties: %{"uuid" => ^uuid_a}},
                     %Bolt.Sips.Types.Node{properties: %{"uuid" => ^uuid_b}},
                     %Bolt.Sips.Types.Node{properties: %{"uuid" => ^uuid_c}}
                   ],
                   relationships: [
                     %Bolt.Sips.Types.UnboundRelationship{id: ^rel_a_b_id},
                     %Bolt.Sips.Types.UnboundRelationship{id: ^rel_b_c_id}
                   ]
                 }
               }
             ] = Neo4jService.get_paths(conn, uuid_a, uuid_c)
    end

    test "the paths from A to D should not exist", ~M{conn, uuid_a, uuid_d} do
      assert [] == Neo4jService.get_paths(conn, uuid_a, uuid_d)
    end
  end
end
