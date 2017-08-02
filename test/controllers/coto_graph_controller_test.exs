defmodule Cotoami.CotoGraphControllerTest do
  use Cotoami.ConnCase
  alias Cotoami.AmishiService
  alias Cotoami.CotoService
  alias Cotoami.CotonomaService
  alias Cotoami.CotoGraphService

  describe "a coto pinned to home" do
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

    test "PUT /api/graph/pin/:coto_id", %{amishi: amishi, coto: coto} do
      {coto2, _posted_in} = CotoService.create!(nil, amishi.id, "bye")

      build_conn()
      |> put_req_header("host", "localhost")
      |> put_req_header("x-requested-with", "XMLHttpRequest")
      |> assign(:amishi, amishi)
      |> put("/api/graph/pin/#{coto2.id}")

      conn =
        build_conn()
        |> assign(:amishi, amishi)
        |> get("/api/graph")

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

    test "PUT /api/graph/pin (multiple cotos)", %{amishi: amishi, coto: coto} do
      {coto2, _posted_in} = CotoService.create!(nil, amishi.id, "coto2")
      {coto3, _posted_in} = CotoService.create!(nil, amishi.id, "coto3")

      build_conn()
      |> put_req_header("host", "localhost")
      |> put_req_header("x-requested-with", "XMLHttpRequest")
      |> assign(:amishi, amishi)
      |> put("/api/graph/pin", %{"coto_ids" => [coto2.id, coto3.id]})

      conn =
        build_conn()
        |> assign(:amishi, amishi)
        |> get("/api/graph")

      {coto_id, coto2_id, coto3_id} = {coto.id, coto2.id, coto3.id}
      assert %{
        "cotos" => %{
          ^coto_id => %{"uuid" => ^coto_id, "content" => "hello"},
          ^coto2_id => %{"uuid" => ^coto2_id, "content" => "coto2"},
          ^coto3_id => %{"uuid" => ^coto3_id, "content" => "coto3"}
        },
        "root_connections" => [
          %{"end" => ^coto3_id, "order" => 3},
          %{"end" => ^coto2_id, "order" => 2},
          %{"end" => ^coto_id, "order" => 1}
        ],
        "connections" => %{}
      } = json_response(conn, 200)
    end

    test "DELETE /api/graph/pin/:coto_id", %{amishi: amishi, coto: coto} do
      build_conn()
      |> put_req_header("host", "localhost")
      |> put_req_header("x-requested-with", "XMLHttpRequest")
      |> assign(:amishi, amishi)
      |> delete("/api/graph/pin/#{coto.id}")

      conn =
        build_conn()
        |> assign(:amishi, amishi)
        |> get("/api/graph")

      assert %{
        "cotos" => %{},
        "root_connections" => [],
        "connections" => %{}
      } == json_response(conn, 200)
    end
  end

  describe "a cotonoma pinned to an amishi" do
    setup do
      amishi = AmishiService.create!("amishi@example.com")
      {{coto, _}, _} = CotonomaService.create!(nil, amishi.id, "cotonoma coto")
      CotoGraphService.pin(coto, amishi)
      %{amishi: amishi, coto: coto}
    end

    test "GET /api/graph", %{amishi: amishi, coto: coto} do
      conn =
        build_conn()
        |> assign(:amishi, amishi)
        |> get("/api/graph")

      coto_id = coto.id
      cotonoma_key = coto.cotonoma.key
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
    setup do
      amishi = AmishiService.create!("amishi@example.com")
      {{_, cotonoma}, _} = CotonomaService.create!(nil, amishi.id, "test")
      {coto, _} = CotoService.create!(cotonoma.id, amishi.id, "hello")
      CotoGraphService.pin(coto, cotonoma, amishi)
      %{amishi: amishi, coto: coto, cotonoma: cotonoma}
    end

    test "GET /api/graph/:cotonoma_key",
        %{amishi: amishi, coto: coto, cotonoma: cotonoma} do
      conn =
        build_conn()
        |> assign(:amishi, amishi)
        |> get("/api/graph/#{cotonoma.key}")

      amishi_id = amishi.id
      coto_id = coto.id
      cotonoma_id = cotonoma.id
      cotonoma_key = cotonoma.key
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
        %{amishi: amishi, coto: coto, cotonoma: cotonoma} do
      {coto2, _posted_in} = CotoService.create!(cotonoma.id, amishi.id, "bye")

      build_conn()
      |> put_req_header("host", "localhost")
      |> put_req_header("x-requested-with", "XMLHttpRequest")
      |> assign(:amishi, amishi)
      |> put("/api/graph/#{cotonoma.key}/pin/#{coto2.id}")

      conn =
        build_conn()
        |> assign(:amishi, amishi)
        |> get("/api/graph/#{cotonoma.key}")

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

    test "PUT /api/graph/:cotonoma_key/pin (multiple cotos)",
        %{amishi: amishi, coto: coto, cotonoma: cotonoma} do
      {coto2, _posted_in} = CotoService.create!(cotonoma.id, amishi.id, "Mario")
      {coto3, _posted_in} = CotoService.create!(cotonoma.id, amishi.id, "Luigi")

      build_conn()
      |> put_req_header("host", "localhost")
      |> put_req_header("x-requested-with", "XMLHttpRequest")
      |> assign(:amishi, amishi)
      |> put("/api/graph/#{cotonoma.key}/pin", %{"coto_ids" => [coto2.id, coto3.id]})

      conn =
        build_conn()
        |> assign(:amishi, amishi)
        |> get("/api/graph/#{cotonoma.key}")

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
        %{amishi: amishi, coto: coto, cotonoma: cotonoma} do
      build_conn()
      |> put_req_header("host", "localhost")
      |> put_req_header("x-requested-with", "XMLHttpRequest")
      |> assign(:amishi, amishi)
      |> delete("/api/graph/#{cotonoma.key}/pin/#{coto.id}")

      conn =
        build_conn()
        |> assign(:amishi, amishi)
        |> get("/api/graph/#{cotonoma.key}")

      assert %{
        "cotos" => %{},
        "root_connections" => [],
        "connections" => %{}
      } == json_response(conn, 200)
    end
  end
end
