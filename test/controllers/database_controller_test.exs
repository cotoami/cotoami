defmodule CotoamiWeb.DatabaseControllerTest do
  use CotoamiWeb.ConnCase
  alias Cotoami.AmishiService
  alias CotoamiWeb.AmishiView

  setup do
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

  @amishi_in_import """
    {
      "id": "7c382e93-c470-4922-b99d-9a179ea692f6",
      "email": "daisuke.marubinotto@gmail.com",
      "display_name": "Daisuke Morita",
      "avatar_url": "https://secure.gravatar.com/avatar/1d413392f15b8659a825fb6bab7396a9",
      "owner": true,
      "updated_at": 1537858884306,
      "inserted_at": 1537858884302
    }
  """

  describe "when there is an empty database" do
    test "import one coto", %{conn: conn} do
      test_import_and_export(
        conn,
        fn (amishi_json) ->
          """
            {
              "cotos": [
                {
                  "id": "5f00e846-6076-4b13-a062-bbe15d2cbffe",
                  "content": "a",
                  "summary": null,
                  "posted_in_id": null,
                  "as_cotonoma": false,
                  "cotonoma": null,
                  "updated_at": 1536569026520,
                  "inserted_at": 1536569026520
                }
              ],
              "connections": [],
              "amishi": #{amishi_json}
            }
          """
        end
      )
    end
  end

  defp test_import_and_export(conn, create_test_data) do
    import_data = create_test_data.(@amishi_in_import)
    post(conn, "/api/import", %{"data" => import_data})

    expected_export_data = 
      conn.assigns.amishi
      |> Phoenix.View.render_one(AmishiView, "export.json")
      |> Poison.encode!()
      |> create_test_data.()
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
