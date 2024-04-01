defmodule Servy.Parser do

  # alias Servy.Conv, as: Conv
  alias Servy.Conv

  def parse(request) do
    [top, params_string] = String.split(request, "\n\n")

    [request_line | header_lines] = top |> String.trim |> String.split("\n")

    [method, path, _] = String.split(request_line, " ")

    headers = parse_headers header_lines, %{}
    params = parse_params headers["Content-Type"], params_string
#
    %Conv{
      method: method,
      path: path,
      params: params,
      headers: headers
    }
  end

  def parse_headers([head | tail], headers) do
    [key, value] = head |> String.trim |> String.split(": ")
    headers = Map.put(headers, key, value)
    parse_headers tail, headers
  end

  def parse_headers([], headers), do: headers

  @doc "Decode query parameters if the content type matches"
  def parse_params("application/x-www-form-urlencoded", params_string) do
    params_string |> String.trim |> URI.decode_query
  end

  def parse_params(_, _), do: %{}
end
