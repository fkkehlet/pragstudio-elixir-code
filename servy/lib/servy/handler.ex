defmodule Servy.Handler do

  @moduledoc "Handles HTTP Requests."

  # @pages_path Path.expand("../../pages", __DIR__)
  @pages_path Path.expand("pages", File.cwd!)

  alias Servy.Conv

  require Logger

  import Servy.Plugins, only: [rewrite_path: 1, log: 1, track: 1]
  import Servy.Parser, only: [parse: 1]
  import Servy.FileHandler, only: [handle_file: 2]

  @doc "Transforms the request into a response."
  def handle(request) do
    request
    |> parse
    |> rewrite_path
    |> log
    |> logger
    |> route
    |> track
    |> emojify
    |> format_response
  end

  def logger(conv) do
    Logger.warning("WARNING")
    conv
  end

  def route(%Conv{method: "GET", path: "/wildthings"} = conv) do
    %{ conv | status: 200, resp_body: "Bears, Lions, Tigers"}
  end

  def route(%Conv{method: "GET", path: "/bears"} = conv) do
    %{ conv | status: 200, resp_body: "Teddy, Smokey, Paddington"}
  end

  def route(%Conv{method: "GET", path: "/bears/new"} = conv) do
    @pages_path
    |> Path.join("form.html")
    |> File.read
    |> handle_file(conv)
  end

  def route(%Conv{method: "GET", path: "/bears/" <> id} = conv) do
    %{ conv | status: 200, resp_body: "Bear #{id}" }
  end

  # name=Baloo&type=Brown
  def route(%Conv{method: "POST", path: "/bears"} = conv) do
    %{ conv | status: 201,
              resp_body: "Created a #{conv.params["type"]} bear named #{conv.params["name"]}!" }
  end

  def route(%Conv{method: "DELETE", path: "/bears/" <> _id} = conv) do
    %{ conv | status: 403, resp_body: "Bears must never be deleted!" }
  end

  def route(%Conv{method: "GET", path: "/about"} = conv) do
    @pages_path
    |> Path.join("about.html")
    |> File.read
    |> handle_file(conv)
  end

  def route(%Conv{method: "GET", path: "/pages/" <> file} = conv) do
    @pages_path
    |> Path.join(file <> ".html")
    |> File.read
    |> handle_file(conv)
  end

  def route(%Conv{ path: path } = conv) do
    %{ conv | status: 404, resp_body: "No #{path} here!" }
  end

  # def route(%{method: "GET", path: "/about"} = conv) do
  #   file =
  #     Path.expand("../../pages", __DIR__)
  #     |> Path.join("about.html")
  #
  #   case File.read(file) do
  #     {:ok, content} ->
  #       %{ conv | status: 200, resp_body: content }
  #
  #     {:error, :enoent} ->
  #       %{ conv | status: 404, resp_body: "File not found" }
  #
  #     {:error, reason} ->
  #       %{ conv | status: 500, resp_body: "File error: #{reason}" }
  #   end
  # end

  # Alternative way
  # def route(conv) do
  #   route(conv, conv.method, conv.path)
  # end
  #
  # def route(conv, "GET", "/wildthings") do
  #   %{ conv | status: 200, resp_body: "Bears, Lions, Tigers"}
  # end
  #
  # def route(conv, "GET", "/bears") do
  #   %{ conv | status: 200, resp_body: "Teddy, Smokey, Paddington"}
  # end
  #
  # def route(conv, "GET", "/bears/" <> id) do
  #   %{ conv | status: 200, resp_body: "Bear #{id}" }
  # end
  #
  # def route(conv, _method, path) do
  #   %{ conv | status: 404, resp_body: "No #{path} here!" }
  # end


  def emojify(%Conv{status: 200} = conv) do
    # TODO: Decorate all responses that have a 200 status with emojies before and after the actual content.
    emojies = String.duplicate("🎉", 5)
    body = "#{emojies}\n" <> conv.resp_body <> "\n#{emojies}"
    %{ conv | resp_body: body }
  end

  def emojify(%Conv{} = conv), do: conv


  def format_response(%Conv{} = conv) do
    """
    HTTP/1.1 #{Conv.full_status(conv)}
    Content-Type: text/html
    Content-Length: #{byte_size(conv.resp_body)}

    #{conv.resp_body}
    """
  end
end


request = """
  GET /wildthings HTTP/1.1
  Host: example.com
  User-Agent: ExampleBrowser/1.0
  Accept: */*

  """
response = Servy.Handler.handle(request)
IO.puts response


request = """
  GET /bears HTTP/1.1
  Host: example.com
  User-Agent: ExampleBrowser/1.0
  Accept: */*

  """
response = Servy.Handler.handle(request)
IO.puts response


request = """
  DELETE /bears/1 HTTP/1.1
  Host: example.com
  User-Agent: ExampleBrowser/1.0
  Accept: */*

  """
response = Servy.Handler.handle(request)
IO.puts response


request = """
  GET /bigfoot HTTP/1.1
  Host: example.com
  User-Agent: ExampleBrowser/1.0
  Accept: */*

  """
response = Servy.Handler.handle(request)
IO.puts response


request = """
  GET /wildlife HTTP/1.1
  Host: example.com
  User-Agent: ExampleBrowser/1.0
  Accept: */*

  """
response = Servy.Handler.handle(request)
IO.puts response


request = """
  GET /bears?id=1 HTTP/1.1
  Host: example.com
  User-Agent: ExampleBrowser/1.0
  Accept: */*

  """
response = Servy.Handler.handle(request)
IO.puts response


request = """
  GET /about HTTP/1.1
  Host: example.com
  User-Agent: ExampleBrowser/1.0
  Accept: */*

  """
response = Servy.Handler.handle(request)
IO.puts response

request = """
  GET /bears/new HTTP/1.1
  Host: example.com
  User-Agent: ExampleBrowser/1.0
  Accept: */*

  """
response = Servy.Handler.handle(request)
IO.puts response


request = """
  POST /bears HTTP/1.1
  Host: example.com
  User-Agent: ExampleBrowser/1.0
  Accept: */*
  Content-Type: application/x-www-form-urlencoded
  Content-Length: 21

  name=Baloo&type=Brown
  """

response = Servy.Handler.handle(request)
IO.puts response


