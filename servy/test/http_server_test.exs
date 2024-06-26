defmodule HttpServerTest do
  alias Servy.{HttpClient, HttpServer}

  use ExUnit.Case

  test "accepts a request on a socket and sends back a response" do
    # request = """
    # GET /wildthings HTTP/1.1\r
    # Host: example.com\r
    # User-Agent: ExampleBrowser/1.0\r
    # Accept: */*\r
    # \r
    # """

    port = 5678

    test_routes =
      [
        "/wildthings",
        "/bears",
        "/api/bears",
        "/sensors",
        "/about"
      ]

    spawn(HttpServer, :start, [port])

    # Spawn the client processes
    for route <- test_routes do
      task = Task.async(HTTPoison, :get, ["http://localhost:#{port}#{route}"])

      {:ok, response} = Task.await(task)

      assert response.status_code == 200

      # spawn(fn ->
      #   # Send the request
      #   {:ok, response} = HTTPoison.get("http://localhost:#{port}/wildthings")
      #
      #   # Send the response back to the parent
      #   send(caller, {:ok, response})
      # end)
      # receive do
      #   {:ok, response} ->
      #     assert response.status_code == 200
      #     assert response.body == "Bears, Lions, Tigers"
      # end
    end

    # response = HttpClient.send_request(request, 5678)

    # assert response == """
    #        HTTP/1.1 200 OK\r
    #        Content-Type: text/html\r
    #        Content-Length: 20\r
    #        \r
    #        Bears, Lions, Tigers
    #        """
  end
end
