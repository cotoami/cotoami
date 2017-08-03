defmodule Cotoami.CotoGraphControllerTest do
  use Cotoami.ConnCase
  alias Cotoami.{AmishiService, CotoService, CotonomaService, CotoGraphService}

  setup do
    amishi = AmishiService.create!("amishi@example.com")
    conn =
      build_conn()
      |> put_req_header("host", "localhost")
      |> put_req_header("x-requested-with", "XMLHttpRequest")
      |> assign(:amishi, amishi)
    %{conn: conn, amishi: amishi}
  end

  def http_get(path, amishi) do
    build_conn()
    |> assign(:amishi, amishi)
    |> get(path)
  end

  describe "a coto pinned to home" do
    setup %{amishi: amishi} do
      {coto, _posted_in} = CotoService.create!(nil, amishi.id, "hello")
      CotoGraphService.pin(coto, amishi)
      %{coto: coto}
    end

    test "GET /api/graph", %{conn: conn, amishi: amishi, coto: coto} do
      conn = conn |> get("/api/graph")

      {amishi_id, coto_id} = {amishi.id, coto.id}
      assert %{
        "cotos" => %{
          ^coto_id => %{
            "uuid" => ^coto_id,
            "amishi_id" => ^amishi_id,
            "amishi" => %{
              "id" => ^amishi_id,
              "email" => "amishi@example.com"
            },
            "content" => "hello",
            "inserted_at" => _inserted_at,
            "updated_at" => _updated_at
          }
        },
        "root_connections" => [
          %{
            "id" => _connection_id,
            "end" => ^coto_id,
            "order" => 1,
            "created_at" => _created_at,
            "created_by" => ^amishi_id
          }
        ],
        "connections" => %{}
      } = json_response(conn, 200)
    end

    test "PUT /api/graph/pin/:coto_id", %{conn: conn, amishi: amishi, coto: coto} do
      {coto2, _posted_in} = CotoService.create!(nil, amishi.id, "bye")

      conn |> put("/api/graph/pin/#{coto2.id}")

      conn = http_get("/api/graph", amishi)

      {coto_id, coto2_id} = {coto.id, coto2.id}
      assert %{
        "cotos" => %{
          ^coto_id => %{"uuid" => ^coto_id, "content" => "hello"},
          ^coto2_id => %{"uuid" => ^coto2_id, "content" => "bye"}
        },
        "root_connections" => [
          %{"end" => ^coto2_id, "order" => 2},
          %{"end" => ^coto_id, "order" => 1}
        ],
        "connections" => %{}
      } = json_response(conn, 200)
    end

    test "PUT /api/graph/pin (multiple cotos)", %{conn: conn, amishi: amishi, coto: coto} do
      {coto2, _} = CotoService.create!(nil, amishi.id, "plain coto")
      {{coto3, cotonoma3}, _} = CotonomaService.create!(nil, amishi.id, "cotonoma coto")

      conn |> put("/api/graph/pin", %{"coto_ids" => [coto2.id, coto3.id]})

      conn = http_get("/api/graph", amishi)

      {coto_id, coto2_id, coto3_id, cotonoma3_key} =
        {coto.id, coto2.id, coto3.id, cotonoma3.key}
      assert %{
        "cotos" => %{
          ^coto_id => %{"uuid" => ^coto_id, "content" => "hello"},
          ^coto2_id => %{"uuid" => ^coto2_id, "content" => "plain coto"},
          ^coto3_id => %{
            "uuid" => ^coto3_id,
            "content" => "cotonoma coto",
            "cotonoma_key" => ^cotonoma3_key
          }
        },
        "root_connections" => [
          %{"end" => ^coto3_id, "order" => 3},
          %{"end" => ^coto2_id, "order" => 2},
          %{"end" => ^coto_id, "order" => 1}
        ],
        "connections" => %{}
      } = json_response(conn, 200)
    end

    test "DELETE /api/graph/pin/:coto_id", %{conn: conn, amishi: amishi, coto: coto} do
      conn |> delete("/api/graph/pin/#{coto.id}")

      conn = http_get("/api/graph", amishi)

      assert %{
        "cotos" => %{},
        "root_connections" => [],
        "connections" => %{}
      } == json_response(conn, 200)
    end
  end

  describe "a cotonoma pinned to an amishi" do
    setup %{amishi: amishi} do
      {{coto, _}, _} = CotonomaService.create!(nil, amishi.id, "cotonoma coto")
      CotoGraphService.pin(coto, amishi)
      %{coto: coto}
    end

    test "GET /api/graph", %{conn: conn, coto: coto} do
      conn = conn |> get("/api/graph")

      {coto_id, cotonoma_key} = {coto.id, coto.cotonoma.key}
      assert %{
        "cotos" => %{
          ^coto_id => %{
            "uuid" => ^coto_id,
            "cotonoma_key" => ^cotonoma_key
          }
        },
        "root_connections" => [
          %{
            "end" => ^coto_id,
            "order" => 1
          }
        ],
        "connections" => %{}
      } = json_response(conn, 200)
    end
  end

  describe "a coto pinned to a cotonoma" do
    setup %{amishi: amishi} do
      {{_, cotonoma}, _} = CotonomaService.create!(nil, amishi.id, "test")
      {coto, _} = CotoService.create!(cotonoma.id, amishi.id, "hello")
      CotoGraphService.pin(coto, cotonoma, amishi)
      %{coto: coto, cotonoma: cotonoma}
    end

    test "GET /api/graph/:cotonoma_key",
        %{conn: conn, amishi: amishi, coto: coto, cotonoma: cotonoma} do
      conn = conn |> get("/api/graph/#{cotonoma.key}")

      {amishi_id, coto_id, cotonoma_id, cotonoma_key} =
        {amishi.id, coto.id, cotonoma.id, cotonoma.key}
      assert %{
        "cotos" => %{
          ^coto_id => %{
            "uuid" => ^coto_id,
            "amishi_id" => ^amishi_id,
            "amishi" => %{
              "id" => ^amishi_id,
              "email" => "amishi@example.com"
            },
            "content" => "hello",
            "posted_in_id" => ^cotonoma_id,
            "posted_in" => %{
              "id" => ^cotonoma_id,
              "key" => ^cotonoma_key
            },
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

    test "PUT /api/graph/:cotonoma_key/pin/:coto_id",
        %{conn: conn, amishi: amishi, coto: coto, cotonoma: cotonoma} do
      {coto2, _posted_in} = CotoService.create!(cotonoma.id, amishi.id, "bye")

      conn |> put("/api/graph/#{cotonoma.key}/pin/#{coto2.id}")

      conn = http_get("/api/graph/#{cotonoma.key}", amishi)

      {coto_id, coto2_id} = {coto.id, coto2.id}
      assert %{
        "cotos" => %{
          ^coto_id => %{"uuid" => ^coto_id, "content" => "hello"},
          ^coto2_id => %{"uuid" => ^coto2_id, "content" => "bye"}
        },
        "root_connections" => [
          %{"end" => ^coto2_id, "order" => 2},
          %{"end" => ^coto_id, "order" => 1}
        ],
        "connections" => %{}
      } = json_response(conn, 200)
    end

    test "PUT /api/graph/:cotonoma_key/pin/:coto_id (pin a coto by another amishi)",
        %{conn: conn, amishi: amishi, coto: coto, cotonoma: cotonoma} do
      amishi2 = AmishiService.create!("amishi2@example.com")
      CotonomaService.add_member(cotonoma, %{"amishi_id" => amishi2.id})
      {coto2, _posted_in} = CotoService.create!(cotonoma.id, amishi2.id, "bye")

      conn |> put("/api/graph/#{cotonoma.key}/pin/#{coto2.id}")

      conn = http_get("/api/graph/#{cotonoma.key}", amishi)

      {coto_id, coto2_id, amishi_id, amishi2_id} =
        {coto.id, coto2.id, amishi.id, amishi2.id}
      assert %{
        "cotos" => %{
          ^coto_id => %{"uuid" => ^coto_id, "amishi_id" => ^amishi_id},
          ^coto2_id => %{"uuid" => ^coto2_id, "amishi_id" => ^amishi2_id}
        },
        "root_connections" => [
          %{"end" => ^coto2_id, "created_by" => ^amishi_id, "order" => 2},
          %{"end" => ^coto_id, "created_by" => ^amishi_id, "order" => 1}
        ]
      } = json_response(conn, 200)
    end

    test "PUT /api/graph/:cotonoma_key/pin (multiple cotos)",
        %{conn: conn, amishi: amishi, coto: coto, cotonoma: cotonoma} do
      {coto2, _posted_in} = CotoService.create!(cotonoma.id, amishi.id, "Mario")
      {coto3, _posted_in} = CotoService.create!(cotonoma.id, amishi.id, "Luigi")

      conn |> put("/api/graph/#{cotonoma.key}/pin", %{"coto_ids" => [coto2.id, coto3.id]})

      conn = http_get("/api/graph/#{cotonoma.key}", amishi)

      {coto_id, coto2_id, coto3_id} = {coto.id, coto2.id, coto3.id}
      assert %{
        "cotos" => %{
          ^coto_id => %{"uuid" => ^coto_id, "content" => "hello"},
          ^coto2_id => %{"uuid" => ^coto2_id, "content" => "Mario"},
          ^coto3_id => %{"uuid" => ^coto3_id, "content" => "Luigi"}
        },
        "root_connections" => [
          %{"end" => ^coto3_id, "order" => 3},
          %{"end" => ^coto2_id, "order" => 2},
          %{"end" => ^coto_id, "order" => 1}
        ],
        "connections" => %{}
      } = json_response(conn, 200)
    end

    test "DELETE /api/graph/:cotonoma_key/pin/:coto_id",
        %{conn: conn, amishi: amishi, coto: coto, cotonoma: cotonoma} do
      conn |> delete("/api/graph/#{cotonoma.key}/pin/#{coto.id}")

      conn = http_get("/api/graph/#{cotonoma.key}", amishi)

      assert %{
        "cotos" => %{},
        "root_connections" => [],
        "connections" => %{}
      } == json_response(conn, 200)
    end
  end
end
