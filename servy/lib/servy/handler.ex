defmodule Servy.Handler do
  require Logger
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

  def track(%{status: 404, path: path} = conv) do
    IO.puts "Warning: #{path} is on the loose!"
    conv
  end

  def track(conv), do: conv

  def log(conv), do: IO.inspect conv

  def logger(conv) do
    Logger.warning("WARNING")
    conv
  end

  def parse request do
    [method, path, _] =
      request
      |> String.trim_leading
      |> String.split("\n")
      |> List.first
      |> String.split(" ")

    %{
      method: method,
      path: path,
      resp_body: "",
      status: nil,
    }
  end

  def rewrite_path(%{path: "/wildlife"} = conv) do
    %{ conv | path: "/wildthings" }
  end

  def rewrite_path(%{path: path} = conv) do
    regex = ~r{\/(?<thing>\w+)\?id=(?<id>\d+)}
    captures = Regex.named_captures(regex, path)
    # rewrite_path_captures(captures, conv)
    %{ conv | path: "/#{captures["thing"]}/#{captures["id"]}"}
  end

  def rewrite_path(conv), do: conv

  # def rewrite_path_captures(%{"thing" => thing, "id" => id}, conv) do
  #   %{ conv | path: "/#{thing}/#{id}"}
  # end
  # def rewrite_path_captures(nil, conv), do: conv

  def route(%{method: "GET", path: "/wildthings"} = conv) do
    %{ conv | status: 200, resp_body: "Bears, Lions, Tigers"}
  end

  def route(%{method: "GET", path: "/bears"} = conv) do
    %{ conv | status: 200, resp_body: "Teddy, Smokey, Paddington"}
  end

  def route(%{method: "GET", path: "/bears/" <> id} = conv) do
    %{ conv | status: 200, resp_body: "Bear #{id}" }
  end

  def route(%{method: "DELETE", path: "/bears/" <> _id} = conv) do
    %{ conv | status: 403, resp_body: "Bears must never be deleted!" }
  end

  def route(%{ path: path } = conv) do
    %{ conv | status: 404, resp_body: "No #{path} here!" }
  end

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


  def emojify(%{status: 200} = conv) do
    # TODO: Decorate all responses that have a 200 status with emojies before and after the actual content.
    emojies = String.duplicate("🎉", 5)
    body = "#{emojies}\n" <> conv.resp_body <> "\n#{emojies}"
    %{ conv | resp_body: body }
  end

  def emojify(conv), do: conv


  def format_response(conv) do
    """
    HTTP/1.1 #{conv.status} #{status_reason(conv.status)}
    Content-Type: text/html
    Content-Length: #{byte_size(conv.resp_body)}

    #{conv.resp_body}
    """
  end

  defp status_reason(code) do
    %{
      200 => "OK",
      201 => "Created",
      401 => "Unauthorized",
      403 => "Forbidden",
      404 => "Not Found",
      500 => "Internal Server Error",
    }[code]
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
  GET /bears/1 HTTP/1.1
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
