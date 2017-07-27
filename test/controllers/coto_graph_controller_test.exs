defmodule Cotoami.CotoGraphControllerTest do
  use Cotoami.ConnCase
  alias Cotoami.AmishiService
  alias Cotoami.CotoService
  alias Cotoami.CotoGraphService

  describe "cotos pinned to home" do
    setup do
      amishi = AmishiService.create!("amishi@example.com")
      {coto, _posted_in} = CotoService.create!(nil, amishi.id, "hello")
      CotoGraphService.pin(coto, amishi)
      %{amishi: amishi, coto: coto}
    end

    test "GET /api/graph", %{amishi: amishi, coto: coto} do
      conn =
        build_conn()
        |> assign(:amishi, amishi)
        |> get("/api/graph")

      amishi_id = amishi.id
      coto_id = coto.id
      assert %{
        "cotos" => %{
          ^coto_id => %{
            "uuid" => ^coto_id,
            "amishi_id" => ^amishi_id,
            "content" => "hello",
            "inserted_at" => _inserted_at,
            "updated_at" => _updated_at
          }
        },
        "root_connections" => [
          %{
            "id" => _connection_id,
            "order" => 1,
            "created_at" => _created_at,
            "created_by" => ^amishi_id
          }
        ],
        "connections" => %{}
      } = json_response(conn, 200)
    end
  end
end
