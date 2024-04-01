defmodule Servy.Parser do
  # alias Servy.Conv, as: Conv
  alias Servy.Conv

  def parse(request) do
    [top, params_string] = String.split(request, "\n\n")

    [request_line | header_lines] = top |> String.trim() |> String.split("\n")

    [method, path, _] = String.split(request_line, " ")

    # headers = parse_headers(header_lines, %{})
    headers = parse_headers(header_lines)
    params = parse_params(headers["Content-Type"], params_string)

    %Conv{
      method: method,
      path: path,
      params: params,
      headers: headers
    }
  end

  # OLD WAY, WITH RECURSION
  # def parse_headers([h | t], headers) do
  #   # Key: value
  #   [k, v] = h |> String.trim() |> String.split(": ")
  #   headers = Map.put(headers, k, v)
  #   parse_headers(t, headers)
  # end
  #
  # def parse_headers([], headers), do: headers

  defp parse_headers(header_lines) do
    Enum.reduce(header_lines, %{}, fn(line, current_map) ->
      [k, v] = line |> String.trim() |> String.split(": ")
      Map.put(current_map, k, v)
    end)
  end

  defp parse_params("application/x-www-form-urlencoded", params_string) do
    params_string |> String.trim() |> URI.decode_query()
  end

  defp parse_params(_, _), do: %{}
end
