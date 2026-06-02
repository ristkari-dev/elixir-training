defmodule TrackerWeb.PageControllerTest do
  use TrackerWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ "Peace of mind from prototype to production"
  end

  @tag :pending
  test "GET /ping returns pong", %{conn: conn} do
    conn = get(conn, ~p"/ping")
    assert text_response(conn, 200) == "pong"
  end
end
