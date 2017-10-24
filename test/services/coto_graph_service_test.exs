defmodule Cotoami.CotoGraphServiceTest do
  use Cotoami.ModelCase
  import ShorterMaps
  alias Cotoami.{
    Coto, CotoGraph,
    CotoGraphService, Neo4jService, AmishiService, CotoService, CotonomaService
  }
  alias Bolt.Sips.Types.Node
  alias Bolt.Sips.Types.Relationship

  setup do
    amishi = AmishiService.create!("amishi@example.com")
    %{conn: Bolt.Sips.conn, amishi: amishi}
  end

  describe "when a coto is pinned to an amishi" do
    setup ~M{conn, amishi} do
      {coto, _posted_in} = CotoService.create!("hello", amishi.id)
      CotoGraphService.pin(conn, coto, amishi)
      ~M{coto}
    end

    test "it should be reflected in the neo4j",
        %{conn: conn, amishi: %{id: amishi_id}, coto: %{id: coto_id}} do
      assert %Node{
        id: amishi_node_id,
        labels: ["Amishi"],
        properties: %{"uuid" => ^amishi_id}
      } = Neo4jService.get_or_create_node(conn, amishi_id)

      assert %Node{
        id: coto_node_id,
        labels: ["Coto"],
        properties: %{
          "uuid" => ^coto_id,
          "content" => "hello",
          "amishi_id" => ^amishi_id,
          "inserted_at" => _inserted_at,
          "updated_at" => _updated_at
        }
      } = Neo4jService.get_or_create_node(conn, coto_id)

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
      ] = Neo4jService.get_ordered_relationships(conn, amishi_id, "HAS_A")
    end

    test "it can be unpinned", ~M{conn, amishi, coto} do
      CotoGraphService.unpin(conn, coto, amishi)
      assert [] == Neo4jService.get_ordered_relationships(conn, amishi.id, "HAS_A")
    end

    test "it can be gotten as a graph",
        %{conn: conn, amishi: %{id: amishi_id} = amishi, coto: %{id: coto_id}} do
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

  describe "when a cotonoma is pinned to an amishi" do
    setup ~M{conn, amishi} do
      {coto, _} = CotonomaService.create!("cotonoma coto", amishi)
      CotoGraphService.pin(conn, coto, amishi)
      ~M{coto}
    end

    test "it should be reflected in the neo4j", %{
      conn: conn,
      amishi: %{id: amishi_id},
      coto: %{id: coto_id, cotonoma: %{key: cotonoma_key}}
    } do
      assert %Node{id: amishi_node_id} =
        Neo4jService.get_or_create_node(conn, amishi_id)

      assert %Node{
        id: coto_node_id,
        labels: labels,
        properties: %{
          "uuid" => ^coto_id,
          "content" => "cotonoma coto",
          "cotonoma_key" => ^cotonoma_key
        }
      } = Neo4jService.get_or_create_node(conn, coto_id)
      assert ["Coto", "Cotonoma"] == Enum.sort(labels)

      assert [
        %Relationship{
          start: ^amishi_node_id,
          end: ^coto_node_id
        }
      ] = Neo4jService.get_ordered_relationships(conn, amishi_id, "HAS_A")
    end
  end

  describe "when a coto is pinned to a cotonoma" do
    setup ~M{conn, amishi} do
      cotonoma_owner = AmishiService.create!("cotonoma@example.com")
      {%Coto{cotonoma: cotonoma}, _} = CotonomaService.create!("test", cotonoma_owner)

      coto_amishi = AmishiService.create!("coto@example.com")
      {coto, _} = CotoService.create!("hello", coto_amishi.id)

      CotoGraphService.pin(conn, coto, cotonoma, amishi)

      ~M{coto, coto_amishi, cotonoma}
    end

    test "it should be reflected in the neo4j", %{
      conn: conn,
      amishi: %{id: amishi_id},
      coto: %{id: coto_id, amishi_id: coto_amishi_id},
      cotonoma: %{
        id: cotonoma_id,
        owner: %{id: cotonoma_owner_id},
        coto: %{id: cotonoma_coto_id}
      }
    } do
      assert %Node{
        id: coto_node_id,
        labels: ["Coto"],
        properties: %{
          "uuid" => ^coto_id,
          "content" => "hello",
          "amishi_id" => ^coto_amishi_id
        }
      } = Neo4jService.get_or_create_node(conn, coto_id)

      assert %Node{
        id: cotonoma_node_id,
        labels: labels,
        properties: %{
          "uuid" => ^cotonoma_coto_id,
          "content" => "test",
          "amishi_id" => ^cotonoma_owner_id
        }
      } = Neo4jService.get_or_create_node(conn, cotonoma_coto_id)
      assert ["Coto", "Cotonoma"] == Enum.sort(labels)

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
      ] = Neo4jService.get_ordered_relationships(conn, cotonoma_coto_id, "HAS_A")
    end

    test "it can be unpinned by the amishi who pinned", ~M{conn, amishi, coto, cotonoma} do
      CotoGraphService.unpin(conn, coto, cotonoma, amishi)
      assert [] == Neo4jService.get_ordered_relationships(conn, cotonoma.coto.id, "HAS_A")
      assert CotoGraphService.count_connections_in_cotonoma(conn, cotonoma) == 0
    end

    test "it can be unpinned by the cotonoma owner", ~M{conn, coto, cotonoma} do
      CotoGraphService.unpin(conn, coto, cotonoma, cotonoma.owner)
      assert [] == Neo4jService.get_ordered_relationships(conn, cotonoma.coto.id, "HAS_A")
      assert CotoGraphService.count_connections_in_cotonoma(conn, cotonoma) == 0
    end

    test "it can't be unpinned by the coto amishi", ~M{conn, coto, coto_amishi, cotonoma} do
      assert_raise Cotoami.Exceptions.NoPermission, fn ->
        CotoGraphService.unpin(conn, coto, cotonoma, coto_amishi)
      end
    end

    test "it can't be unpinned by an unrelated amishi", ~M{conn, coto, cotonoma} do
      unrelated_amishi = AmishiService.create!("unrelated@example.com")
      assert_raise Cotoami.Exceptions.NoPermission, fn ->
        CotoGraphService.unpin(conn, coto, cotonoma, unrelated_amishi)
      end
    end

    test "the cotonoma has one connection", ~M{conn, cotonoma} do
      assert CotoGraphService.count_connections_in_cotonoma(conn, cotonoma) == 1
    end
  end

  describe "when two cotos are connected" do
    setup ~M{conn, amishi} do
      source_amishi = AmishiService.create!("source@example.com")
      {source, _} = CotoService.create!("hello", source_amishi.id)
      source = %{source | amishi: source_amishi}

      target_amishi = AmishiService.create!("target@example.com")
      {target, _} = CotoService.create!("bye", target_amishi.id)

      CotoGraphService.connect(conn, source, target, amishi)
      ~M{source, source_amishi, target, target_amishi}
    end

    test "it should be reflected in the neo4j", ~M{conn, amishi, source, target} do
      amishi_id = amishi.id
      source_node_id = Neo4jService.get_or_create_node(conn, source.id).id
      target_node_id = Neo4jService.get_or_create_node(conn, target.id).id

      assert [
        %Relationship{
          start: ^source_node_id,
          end: ^target_node_id,
          properties: %{
            "created_at" => _created_at,
            "created_by" => ^amishi_id,
            "order" => 1
          },
          type: "HAS_A"
        }
      ] = Neo4jService.get_ordered_relationships(conn, source.id, "HAS_A")
    end

    test "they can be disconnected by the amishi who connected", ~M{conn, amishi, source, target} do
      CotoGraphService.disconnect(conn, source, target, amishi)
      assert [] = Neo4jService.get_ordered_relationships(conn, source.id, "HAS_A")
    end

    test "they can be disconnected by the source amishi", ~M{conn, source, source_amishi, target} do
      CotoGraphService.disconnect(conn, source, target, source_amishi)
      assert [] = Neo4jService.get_ordered_relationships(conn, source.id, "HAS_A")
    end

    test "they can't be disconnected by the target amishi", ~M{conn, source, target, target_amishi} do
      assert_raise Cotoami.Exceptions.NoPermission, fn ->
        CotoGraphService.disconnect(conn, source, target, target_amishi)
      end
    end

    test "they can't be disconnected by an unrelated amishi", ~M{conn, source, target} do
      unrelated_amishi = AmishiService.create!("unrelated@example.com")
      assert_raise Cotoami.Exceptions.NoPermission, fn ->
        CotoGraphService.disconnect(conn, source, target, unrelated_amishi)
      end
    end
  end

  describe "when there are two paths to the same cotos" do
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

    test "the graph should not have duplicate connections",
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
