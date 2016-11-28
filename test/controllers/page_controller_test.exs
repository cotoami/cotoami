defmodule Cotoami.PageControllerTest do
  use Cotoami.ConnCase

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "Hello Cotoami!"
  end
end
