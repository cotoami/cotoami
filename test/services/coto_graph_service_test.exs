defmodule Cotoami.CotoGraphServiceTest do
  use Cotoami.ModelCase
  import ShorterMaps
  alias Cotoami.{
    Coto, CotoGraph,
    CotoGraphService, Neo4jService, AmishiService, CotoService, CotonomaService
  }
  alias Bolt.Sips.Types.Relationship

  setup do
    amishi = AmishiService.create!("amishi@example.com")
    %{conn: Bolt.Sips.conn, amishi: amishi}
  end

  describe "a coto pinned to an amishi" do
    setup ~M{conn, amishi} do
      {coto, _posted_in} = CotoService.create!("hello", amishi.id)
      CotoGraphService.pin(conn, coto, amishi)
      ~M{coto}
    end

    test "pin", ~M{conn, amishi, coto} do
      amishi_id = amishi.id
      coto_id = coto.id

      amishi_node = Neo4jService.get_or_create_node(conn, amishi.id)
      amishi_node_id = amishi_node.id
      assert ["Amishi"] == amishi_node.labels
      assert %{"uuid" => amishi.id} == amishi_node.properties

      coto_node = Neo4jService.get_or_create_node(conn, coto.id)
      coto_node_id = coto_node.id
      assert ["Coto"] == coto_node.labels
      assert %{
        "uuid" => ^coto_id,
        "content" => "hello",
        "amishi_id" => ^amishi_id,
        "inserted_at" => _inserted_at,
        "updated_at" => _updated_at
      } = coto_node.properties

      assert [
        %Relationship{
          start: ^amishi_node_id,
          end: ^coto_node_id,
          properties: %{
            "created_at" => _created_at,
            "created_by" => ^amishi_id,
            "order" => 1
          },
          type: "HAS_A"
        }
      ] = Neo4jService.get_ordered_relationships(conn, amishi.id, "HAS_A")
    end

    test "unpin", ~M{conn, amishi, coto} do
      CotoGraphService.unpin(conn, coto, amishi)
      assert [] == Neo4jService.get_ordered_relationships(conn, amishi.id, "HAS_A")
    end

    test "graph", ~M{conn, amishi, coto} do
      coto_id = coto.id
      amishi_id = amishi.id
      assert %CotoGraph{
        cotos: %{
          ^coto_id => %{
            "uuid" => ^coto_id,
            "amishi_id" => ^amishi_id,
            "amishi" => %{
              id: ^amishi_id,
              email: "amishi@example.com"
            },
            "content" => "hello",
            "inserted_at" => _inserted_at,
            "updated_at" => _updated_at
          }
        },
        root_connections: [
          %{
            "id" => _rel_id,
            "end" => ^coto_id,
            "order" => 1,
            "created_at" => _created_at,
            "created_by" => ^amishi_id
          }
        ],
        connections: %{}
      } = CotoGraphService.get_graph(conn, amishi)
    end
  end

  describe "a cotonoma pinned to an amishi" do
    setup ~M{conn, amishi} do
      {coto, _} = CotonomaService.create!("cotonoma coto", amishi)
      CotoGraphService.pin(conn, coto, amishi)
      ~M{coto}
    end

    test "pin", ~M{conn, amishi, coto} do
      amishi_node = Neo4jService.get_or_create_node(conn, amishi.id)
      amishi_node_id = amishi_node.id

      coto_id = coto.id
      cotonoma_key = coto.cotonoma.key
      coto_node = Neo4jService.get_or_create_node(conn, coto.id)
      coto_node_id = coto_node.id
      assert ["Coto", "Cotonoma"] == Enum.sort(coto_node.labels)
      assert %{
        "uuid" => ^coto_id,
        "content" => "cotonoma coto",
        "cotonoma_key" => ^cotonoma_key
      } = coto_node.properties

      assert [
        %Relationship{
          start: ^amishi_node_id,
          end: ^coto_node_id
        }
      ] = Neo4jService.get_ordered_relationships(conn, amishi.id, "HAS_A")
    end
  end

  describe "a coto pinned to a cotonoma" do
    setup ~M{conn, amishi} do
      {%Coto{cotonoma: cotonoma}, _} = CotonomaService.create!("test", amishi)
      {coto, _} = CotoService.create!("hello", amishi.id)
      CotoGraphService.pin(conn, coto, cotonoma, amishi)
      ~M{coto, cotonoma}
    end

    test "pin", ~M{conn, amishi, coto, cotonoma} do
      amishi_id = amishi.id
      cotonoma_id = cotonoma.id
      cotonoma_coto_id = cotonoma.coto.id

      coto_node = Neo4jService.get_or_create_node(conn, coto.id)
      coto_node_id = coto_node.id

      cotonoma_node = Neo4jService.get_or_create_node(conn, cotonoma.coto.id)
      cotonoma_node_id = cotonoma_node.id
      assert ["Coto", "Cotonoma"] == Enum.sort(cotonoma_node.labels)
      assert %{
        "uuid" => ^cotonoma_coto_id,
        "content" => "test",
        "amishi_id" => ^amishi_id,
        "inserted_at" => _inserted_at,
        "updated_at" => _updated_at
      } = cotonoma_node.properties

      assert [
        %Relationship{
          start: ^cotonoma_node_id,
          end: ^coto_node_id,
          properties: %{
            "created_at" => _created_at,
            "created_by" => ^amishi_id,
            "created_in" => ^cotonoma_id,
            "order" => 1
          },
          type: "HAS_A"
        }
      ] = Neo4jService.get_ordered_relationships(conn, cotonoma.coto.id, "HAS_A")
    end

    test "unpin", ~M{conn, coto, cotonoma} do
      CotoGraphService.unpin(conn, coto, cotonoma)
      assert [] == Neo4jService.get_ordered_relationships(conn, cotonoma.coto.id, "HAS_A")
    end
  end

  describe "two cotos with a connection" do
    setup ~M{conn, amishi} do
      {coto1, _posted_in} = CotoService.create!("hello", amishi.id)
      {coto2, _posted_in} = CotoService.create!("bye", amishi.id)
      CotoGraphService.connect(conn, coto1, coto2, amishi)
      ~M{coto1, coto2}
    end

    test "connection", ~M{conn, amishi, coto1, coto2} do
      amishi_id = amishi.id
      coto1_node_id = Neo4jService.get_or_create_node(conn, coto1.id).id
      coto2_node_id = Neo4jService.get_or_create_node(conn, coto2.id).id

      assert [
        %Relationship{
          start: ^coto1_node_id,
          end: ^coto2_node_id,
          properties: %{
            "created_at" => _created_at,
            "created_by" => ^amishi_id,
            "order" => 1
          },
          type: "HAS_A"
        }
      ] = Neo4jService.get_ordered_relationships(conn, coto1.id, "HAS_A")
    end

    test "disconnect", ~M{conn, amishi, coto1, coto2} do
      CotoGraphService.disconnect(conn, %{coto1 | amishi: amishi}, coto2, amishi)
      assert [] = Neo4jService.get_ordered_relationships(conn, coto1.id, "HAS_A")
    end
  end

  describe "two paths to the same cotos" do
    # a -> b
    # c -> a -> b
    setup ~M{conn, amishi} do
      {coto_a, _posted_in} = CotoService.create!("a", amishi.id)
      {coto_b, _posted_in} = CotoService.create!("b", amishi.id)
      {coto_c, _posted_in} = CotoService.create!("c", amishi.id)
      CotoGraphService.connect(conn, coto_a, coto_b, amishi)
      CotoGraphService.connect(conn, coto_c, coto_a, amishi)
      ~M{coto_a, coto_b, coto_c}
    end

    test "graph (ensure no duplicate connections)",
        ~M{conn, amishi, coto_a, coto_b, coto_c} do
      {coto_a_id, coto_b_id, coto_c_id} = {coto_a.id, coto_b.id, coto_c.id}
      assert %CotoGraph{
        root_connections: [],
        connections: %{
          ^coto_a_id => [%{"start" => ^coto_a_id, "end" => ^coto_b_id}],
          ^coto_c_id => [%{"start" => ^coto_c_id, "end" => ^coto_a_id}]
        }
      } = CotoGraphService.get_graph(conn, amishi)
    end
  end
end
