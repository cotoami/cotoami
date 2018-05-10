defmodule CotoamiWeb.PageControllerTest do
  use CotoamiWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "Cotoami"
  end
end
