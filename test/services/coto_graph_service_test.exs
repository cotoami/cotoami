defmodule Cotoami.CotoGraphServiceTest do
  use Cotoami.ModelCase
  alias Cotoami.CotoGraphService
  alias Cotoami.Neo4jService
  alias Cotoami.AmishiService
  alias Cotoami.CotoService
  alias Bolt.Sips.Types.Relationship

  describe "an amishi has cotos" do
    setup do
      conn = Bolt.Sips.conn
      amishi = AmishiService.create!("amishi@example.com")
      {coto, _posted_in} = CotoService.create!(nil, amishi.id, "hello")
      CotoGraphService.pin(coto, amishi)
      %{conn: conn, amishi: amishi, coto: coto}
    end

    test "create", %{conn: conn, amishi: amishi, coto: coto} do
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
        "uuid" => coto_id,
        "content" => "hello",
        "amishi_id" => amishi_id,
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
  end
end
