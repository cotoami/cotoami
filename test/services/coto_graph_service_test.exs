defmodule Cotoami.CotoGraphServiceTest do
  use Cotoami.ModelCase
  alias Bolt.Sips
  alias Cotoami.{
    CotoGraphService, Neo4jService, AmishiService, CotoService,
    CotonomaService, CotoGraph
  }
  alias Bolt.Sips.Types.Relationship

  setup do
    amishi = AmishiService.create!("amishi@example.com")
    %{conn: Bolt.Sips.conn, amishi: amishi}
  end

  describe "a coto pinned to an amishi" do
    setup %{amishi: amishi} do
      {coto, _posted_in} = CotoService.create!(nil, amishi.id, "hello")
      CotoGraphService.pin(Sips.conn, coto, amishi)
      %{coto: coto}
    end

    test "pin", %{conn: conn, amishi: amishi, coto: coto} do
      amishi_id = amishi.id
      coto_id = coto.id

      amishi_node = Neo4jService.get_or_create_node!(conn, amishi.id)
      amishi_node_id = amishi_node.id
      assert ["Amishi"] == amishi_node.labels
      assert %{"uuid" => amishi.id} == amishi_node.properties

      coto_node = Neo4jService.get_or_create_node!(conn, coto.id)
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
      ] = Neo4jService.get_ordered_relationships!(conn, amishi.id, "HAS_A")
    end

    test "unpin", %{conn: conn, amishi: amishi, coto: coto} do
      CotoGraphService.unpin(Sips.conn, coto, amishi)
      assert [] == Neo4jService.get_ordered_relationships!(conn, amishi.id, "HAS_A")
    end

    test "graph", %{amishi: amishi, coto: coto} do
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
      } = CotoGraphService.get_graph(Sips.conn, amishi)
    end
  end

  describe "a cotonoma pinned to an amishi" do
    setup %{amishi: amishi} do
      {{coto, _}, _} = CotonomaService.create!(nil, amishi.id, "cotonoma coto")
      CotoGraphService.pin(Sips.conn, coto, amishi)
      %{coto: coto}
    end

    test "pin", %{conn: conn, amishi: amishi, coto: coto} do
      amishi_node = Neo4jService.get_or_create_node!(conn, amishi.id)
      amishi_node_id = amishi_node.id

      coto_id = coto.id
      cotonoma_key = coto.cotonoma.key
      coto_node = Neo4jService.get_or_create_node!(conn, coto.id)
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
      ] = Neo4jService.get_ordered_relationships!(conn, amishi.id, "HAS_A")
    end
  end

  describe "a coto pinned to a cotonoma" do
    setup %{amishi: amishi} do
      {{_, cotonoma}, _} = CotonomaService.create!(nil, amishi.id, "test")
      {coto, _} = CotoService.create!(nil, amishi.id, "hello")
      CotoGraphService.pin(Sips.conn, coto, cotonoma, amishi)
      %{coto: coto, cotonoma: cotonoma}
    end

    test "pin", %{conn: conn, amishi: amishi, coto: coto, cotonoma: cotonoma} do
      amishi_id = amishi.id
      cotonoma_id = cotonoma.id
      cotonoma_coto_id = cotonoma.coto.id

      coto_node = Neo4jService.get_or_create_node!(conn, coto.id)
      coto_node_id = coto_node.id

      cotonoma_node = Neo4jService.get_or_create_node!(conn, cotonoma.coto.id)
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
      ] = Neo4jService.get_ordered_relationships!(conn, cotonoma.coto.id, "HAS_A")
    end

    test "unpin", %{conn: conn, coto: coto, cotonoma: cotonoma} do
      CotoGraphService.unpin(Sips.conn, coto, cotonoma)
      assert [] == Neo4jService.get_ordered_relationships!(conn, cotonoma.coto.id, "HAS_A")
    end
  end

  describe "two cotos with a connection" do
    setup %{amishi: amishi} do
      {coto1, _posted_in} = CotoService.create!(nil, amishi.id, "hello")
      {coto2, _posted_in} = CotoService.create!(nil, amishi.id, "bye")
      CotoGraphService.connect(Sips.conn, coto1, coto2, amishi)
      %{coto1: coto1, coto2: coto2}
    end

    test "connection", %{conn: conn, amishi: amishi, coto1: coto1, coto2: coto2} do
      amishi_id = amishi.id
      amishi_node_id = Neo4jService.get_or_create_node!(conn, amishi.id).id
      coto1_node_id = Neo4jService.get_or_create_node!(conn, coto1.id).id
      coto2_node_id = Neo4jService.get_or_create_node!(conn, coto2.id).id

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
      ] = Neo4jService.get_ordered_relationships!(conn, coto1.id, "HAS_A")

      # the source node should be pinned
      assert [
        %Relationship{
          start: ^amishi_node_id,
          end: ^coto1_node_id,
          properties: %{
            "created_by" => ^amishi_id,
            "order" => 1
          },
          type: "HAS_A"
        }
      ] = Neo4jService.get_ordered_relationships!(conn, amishi_id, "HAS_A")
    end

    test "disconnect", %{conn: conn, amishi: amishi, coto1: coto1, coto2: coto2} do
      CotoGraphService.disconnect(Sips.conn, coto1, coto2, amishi)
      assert [] = Neo4jService.get_ordered_relationships!(conn, coto1.id, "HAS_A")
    end
  end
end
