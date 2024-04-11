defmodule HttpServerTest do
  alias Servy.{HttpClient, HttpServer}

  use ExUnit.Case

  test "send a request to the server and verify the response" do
    request = """
    GET /wildthings HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    \r
    """

    spawn(HttpServer, :start, [5678])

    response = HttpClient.send_request(request, 5678)

    assert response == """
           HTTP/1.1 200 OK\r
           Content-Type: text/html\r
           Content-Length: 20\r
           \r
           Bears, Lions, Tigers
           """
  end
end
