defmodule PlugTest do
  use ExUnit.Case, async: true
  import Plug.Test
  import Plug.Conn

  @tag :pending
  test "Greeter sets the x-greeting response header" do
    conn = Greeter.call(conn(:get, "/"), Greeter.init([]))
    assert get_resp_header(conn, "x-greeting") == ["hello"]
  end

  @tag :pending
  test "AuthPlug halts with 401 when the token is missing" do
    conn = AuthPlug.call(conn(:get, "/"), AuthPlug.init([]))
    assert conn.halted
    assert conn.status == 401
  end

  @tag :pending
  test "AuthPlug passes the conn through when the token is correct" do
    conn =
      conn(:get, "/")
      |> put_req_header("x-token", "secret")
      |> AuthPlug.call(AuthPlug.init([]))

    refute conn.halted
  end

  @tag :pending
  test "ApiRouter serves /hello publicly" do
    conn = ApiRouter.call(conn(:get, "/hello"), ApiRouter.init([]))
    assert conn.status == 200
    assert conn.resp_body == "hello"
  end

  @tag :pending
  test "ApiRouter guards /secret with AuthPlug" do
    unauthed = ApiRouter.call(conn(:get, "/secret"), ApiRouter.init([]))
    assert unauthed.status == 401

    authed =
      conn(:get, "/secret")
      |> put_req_header("x-token", "secret")
      |> ApiRouter.call(ApiRouter.init([]))

    assert authed.status == 200
    assert authed.resp_body == "top secret"
  end
end
