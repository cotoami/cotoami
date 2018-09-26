defmodule CotoamiWeb.DatabaseControllerTest do
  use CotoamiWeb.ConnCase
  alias Cotoami.{AmishiService, Neo4jService}
  alias CotoamiWeb.AmishiView

  setup do
    Neo4jService.clear_database(Bolt.Sips.conn)
    owner =
      AmishiService.create!("owner@cotoa.me")
      |> Map.put(:owner, true)
    conn =
      build_conn()
      |> put_req_header("host", "localhost")
      |> put_req_header("x-requested-with", "XMLHttpRequest")
      |> put_req_header("x-cotoami-client-id", "this-is-a-client-id")
      |> assign(:amishi, owner)
    %{conn: conn}
  end

  @amishi_id_in_import "1983b738-b9eb-4a20-88c1-b6e9c92fa84c"

  @amishi_in_import """
    {
      "updated_at": 1537943474281,
      "owner": true,
      "inserted_at": 1537943474274,
      "id": "#{@amishi_id_in_import}",
      "email": "daisuke.marubinotto@gmail.com",
      "display_name": "Daisuke Morita",
      "avatar_url": "https://secure.gravatar.com/avatar/1d413392f15b8659a825fb6bab7396a9"
    }
  """

  describe "import and export: " do
    test "one coto", %{conn: conn} do
      test_import_and_export(
        conn,
        fn (_amishi_id, amishi_json) ->
          """
            {
              "cotos": [
                {
                  "updated_at": 1537943597410,
                  "summary": null,
                  "posted_in_id": null,
                  "inserted_at": 1537943597410,
                  "id": "e4910f38-5756-4ac4-a995-09d14cfa5874",
                  "cotonoma": null,
                  "content": "hello",
                  "as_cotonoma": false
                }
              ],
              "connections": [],
              "amishi": #{amishi_json}
            }
          """
        end,
        %{
          "cotos" => %{"inserts" => 1, "updates" => 0, "cotonomas" => 0, "rejected" => []},
          "connections" => %{"ok" => 0, "rejected" => []}
        }
      )
    end

    test "one coto pinned", %{conn: conn} do
      test_import_and_export(
        conn,
        fn (amishi_id, amishi_json) ->
          """
            {
              "cotos": [
                {
                  "updated_at": 1537943597410,
                  "summary": null,
                  "posted_in_id": null,
                  "inserted_at": 1537943597410,
                  "id": "e4910f38-5756-4ac4-a995-09d14cfa5874",
                  "cotonoma": null,
                  "content": "hello",
                  "as_cotonoma": false
                }
              ],
              "connections": [
                {
                  "start": "#{amishi_id}",
                  "order": 1,
                  "end": "e4910f38-5756-4ac4-a995-09d14cfa5874",
                  "created_by": "#{amishi_id}",
                  "created_at": 1537943695452
                }
              ],
              "amishi": #{amishi_json}
            }
          """
        end,
        %{
          "cotos" => %{"inserts" => 1, "updates" => 0, "cotonomas" => 0, "rejected" => []},
          "connections" => %{"ok" => 1, "rejected" => []}
        }
      )
    end

    test "two cotos connected and pinned", %{conn: conn} do
      test_import_and_export(
        conn,
        fn (amishi_id, amishi_json) ->
          """
            {
              "cotos": [
                {
                  "updated_at": 1537943597410,
                  "summary": null,
                  "posted_in_id": null,
                  "inserted_at": 1537943597410,
                  "id": "e4910f38-5756-4ac4-a995-09d14cfa5874",
                  "cotonoma": null,
                  "content": "hello",
                  "as_cotonoma": false
                },
                {
                  "updated_at": 1537944841347,
                  "summary": null,
                  "posted_in_id": null,
                  "inserted_at": 1537944841347,
                  "id": "bd9f96df-9639-4986-8473-392a993f3bc3",
                  "cotonoma": null,
                  "content": "bye",
                  "as_cotonoma": false
                }
              ],
              "connections": [
                {
                  "start": "#{amishi_id}",
                  "order": 1,
                  "end": "e4910f38-5756-4ac4-a995-09d14cfa5874",
                  "created_by": "#{amishi_id}",
                  "created_at": 1537943695452
                },
                {
                  "start": "e4910f38-5756-4ac4-a995-09d14cfa5874",
                  "order": 1,
                  "end": "bd9f96df-9639-4986-8473-392a993f3bc3",
                  "created_by": "#{amishi_id}",
                  "created_at": 1537944841465
                }
              ],
              "amishi": #{amishi_json}
            }
          """
        end,
        %{
          "cotos" => %{"inserts" => 2, "updates" => 0, "cotonomas" => 0, "rejected" => []},
          "connections" => %{"ok" => 2, "rejected" => []}
        }
      )
    end

    test "connection's order", %{conn: conn} do
      test_import_and_export(
        conn,
        fn (amishi_id, amishi_json) ->
          """
            {
              "cotos": [
                {
                  "updated_at": 1537943597410,
                  "summary": null,
                  "posted_in_id": null,
                  "inserted_at": 1537943597410,
                  "id": "e4910f38-5756-4ac4-a995-09d14cfa5874",
                  "cotonoma": null,
                  "content": "hello",
                  "as_cotonoma": false
                },
                {
                  "updated_at": 1537944841347,
                  "summary": null,
                  "posted_in_id": null,
                  "inserted_at": 1537944841347,
                  "id": "bd9f96df-9639-4986-8473-392a993f3bc3",
                  "cotonoma": null,
                  "content": "bye",
                  "as_cotonoma": false
                },
                {
                  "updated_at": 1537945267093,
                  "summary": "summary",
                  "posted_in_id": null,
                  "inserted_at": 1537945267093,
                  "id": "30c2c1e7-6e32-479f-bf35-359c02302ed5",
                  "cotonoma": null,
                  "content": "content",
                  "as_cotonoma": false
                }
              ],
              "connections": [
                {
                  "start": "#{amishi_id}",
                  "order": 1,
                  "end": "e4910f38-5756-4ac4-a995-09d14cfa5874",
                  "created_by": "#{amishi_id}",
                  "created_at": 1537943695452
                },
                {
                  "start": "e4910f38-5756-4ac4-a995-09d14cfa5874",
                  "order": 2,
                  "end": "bd9f96df-9639-4986-8473-392a993f3bc3",
                  "created_by": "#{amishi_id}",
                  "created_at": 1537944841465
                },
                {
                  "start": "e4910f38-5756-4ac4-a995-09d14cfa5874",
                  "order": 1,
                  "end": "30c2c1e7-6e32-479f-bf35-359c02302ed5",
                  "created_by": "#{amishi_id}",
                  "created_at": 1537945267162
                }
              ],
              "amishi": #{amishi_json}
            }
          """
        end,
        %{
          "cotos" => %{"inserts" => 3, "updates" => 0, "cotonomas" => 0, "rejected" => []},
          "connections" => %{"ok" => 3, "rejected" => []}
        }
      )
    end
  end

  defp test_import_and_export(conn, create_test_data, stats) do
    import_data = create_test_data.(@amishi_id_in_import, @amishi_in_import)
    conn_posted = post(conn, "/api/import", %{"data" => import_data})
    assert json_response(conn_posted, 200) == stats

    amishi_json_in_export =
      conn.assigns.amishi
      |> Phoenix.View.render_one(AmishiView, "export.json")
      |> Poison.encode!()

    expected_export_data = 
      create_test_data.(conn.assigns.amishi.id, amishi_json_in_export)
      |> format_json()

    conn = get(conn, "/export")
    assert response(conn, 200) == expected_export_data
  end

  defp format_json(json) do
    json
    |> Poison.decode!() 
    |> Poison.encode!(pretty: true)
  end
end
