defmodule Servy.Handler do
  @moduledoc "Handles HTTP Requests."

  # @pages_path Path.expand("../../pages", __DIR__)
  @pages_path Path.expand("pages", File.cwd!())

  alias Servy.Conv
  alias Servy.BearController

  import Servy.Plugins, only: [rewrite_path: 1, log: 1, track: 1]
  import Servy.Parser, only: [parse: 1]
  import Servy.FileHandler, only: [handle_file: 2]

  @doc "Transforms the request into a response."
  def handle(request) do
    request
    |> parse
    |> rewrite_path
    |> log
    |> route
    |> track
    # |> emojify
    |> format_response
  end

  def route(%Conv{method: "GET", path: "/wildthings"} = conv) do
    %{conv | status: 200, resp_body: "Bears, Lions, Tigers"}
  end

  def route(%Conv{method: "GET", path: "/bears"} = conv) do
    BearController.index(conv)
  end

  def route(%Conv{method: "GET", path: "/bears/new"} = conv) do
    @pages_path
    |> Path.join("form.html")
    |> File.read()
    |> handle_file(conv)
  end

  def route(%Conv{method: "GET", path: "/bears/" <> id} = conv) do
    params = Map.put(conv.params, "id", id)
    BearController.show(conv, params)
  end

  def route(%Conv{method: "POST", path: "/bears"} = conv) do
    BearController.create(conv, conv.params)
  end

  def route(%Conv{method: "DELETE", path: "/bears/" <> _id} = conv) do
    BearController.delete(conv)
  end

  def route(%Conv{method: "GET", path: "/about"} = conv) do
    @pages_path
    |> Path.join("about.html")
    |> File.read()
    |> handle_file(conv)
  end

  def route(%Conv{method: "GET", path: "/pages/" <> file} = conv) do
    @pages_path
    |> Path.join(file <> ".html")
    |> File.read()
    |> handle_file(conv)
  end

  def route(%Conv{path: path} = conv) do
    %{conv | status: 404, resp_body: "No #{path} here!"}
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
    %{conv | resp_body: body}
  end

  def emojify(%Conv{} = conv), do: conv

  def format_response(%Conv{} = conv) do
    """
    HTTP/1.1 #{Conv.full_status(conv)}\r
    Content-Type: text/html\r
    Content-Length: #{byte_size(conv.resp_body)}\r
    \r
    #{conv.resp_body}
    """
  end
end
