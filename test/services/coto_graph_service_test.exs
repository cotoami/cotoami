defmodule Cotoami.CotoGraphServiceTest do
  use Cotoami.ModelCase
  alias Cotoami.CotoGraphService
  alias Cotoami.Neo4jService
  alias Cotoami.AmishiService
  alias Cotoami.CotoService
  alias Cotoami.CotonomaService
  alias Cotoami.CotoGraph
  alias Bolt.Sips.Types.Relationship

  describe "cotos pinned to an amishi" do
    setup do
      conn = Bolt.Sips.conn
      amishi = AmishiService.create!("amishi@example.com")
      {coto, _posted_in} = CotoService.create!(nil, amishi.id, "hello")
      CotoGraphService.pin(coto, amishi)
      %{conn: conn, amishi: amishi, coto: coto}
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
      CotoGraphService.unpin(coto, amishi)
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
            "content" => "hello",
            "inserted_at" => _inserted_at,
            "updated_at" => _updated_at
          }
        },
        root_connections: [
          %{
            "id" => _rel_id,
            "order" => 1,
            "created_at" => _created_at,
            "created_by" => ^amishi_id
          }
        ],
        connections: %{}
      } = CotoGraphService.get_graph(amishi)
    end
  end

  describe "cotos pinned to a cotonoma" do
    setup do
      conn = Bolt.Sips.conn
      amishi = AmishiService.create!("amishi@example.com")
      {{_, cotonoma}, _} = CotonomaService.create!(nil, amishi.id, "test")
      {coto, _} = CotoService.create!(nil, amishi.id, "hello")
      CotoGraphService.pin(coto, cotonoma, amishi)
      %{conn: conn, amishi: amishi, coto: coto, cotonoma: cotonoma}
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
      CotoGraphService.unpin(coto, cotonoma)
      assert [] == Neo4jService.get_ordered_relationships!(conn, cotonoma.coto.id, "HAS_A")
    end
  end
end
