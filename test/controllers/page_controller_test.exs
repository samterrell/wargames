defmodule Wargames.PageControllerTest do
  use Wargames.ConnCase

  test "GET /" do
    conn = get conn(), "/"
    assert conn.resp_body =~ "Hello Phoenix!"
  end
end
