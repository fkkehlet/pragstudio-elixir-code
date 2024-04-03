defmodule Servy.Parser do
  # alias Servy.Conv, as: Conv
  alias Servy.Conv

  def parse(request) do
    [top, params_string] = String.split(request, "\r\n\r\n")

    [request_line | header_lines] = top |> String.trim() |> String.split("\r\n")

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
  # def parse_headers([h | t], header_map) do
  #   # Key: value
  #   [k, v] = h |> String.trim() |> String.split(": ")
  #   header_map = Map.put(header_map, k, v)
  #   parse_headers(t, header_map)
  # end
  #
  # def parse_headers([], header_map), do: header_map

  def parse_headers(header_lines) do
    Enum.reduce(header_lines, %{}, fn line, current_map ->
      [k, v] = line |> String.trim() |> String.split(": ")
      Map.put(current_map, k, v)
    end)
  end

  @doc """
  Parses the given param string of the form `key1=value1&key2=value2`
  into a map with corresponding keys and values.

  ## Examples
  iex> params_string = "name=Baloo&type=Brown"
  iex> Servy.Parser.parse_params("application/x-www-form-urlencoded", params_string)
  %{"name" => "Baloo", "type" => "Brown"}
  iex> Servy.Parser.parse_params("multipart/form-data", params_string)
  %{}
  """
  def parse_params("application/x-www-form-urlencoded", params_string) do
    params_string |> String.trim() |> URI.decode_query()
  end

  def parse_params(_, _), do: %{}
end
