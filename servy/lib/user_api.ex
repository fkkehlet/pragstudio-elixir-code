defmodule UserApi do
  def query(id) when is_binary(id) do
    api_url(id)
    |> HTTPoison.get()
    |> handle_response()
  end

  defp api_url(id) do
    "https://jsonplaceholder.typicode.com/users/#{URI.encode(id)}"
  end

  defp handle_response({:ok, %HTTPoison.Response{status_code: 200, body: body}}) do
    city =
      Poison.Parser.parse!(body)
      |> get_in(["address", "city"])

    {:ok, city}
  end

  defp handle_response({:ok, %HTTPoison.Response{status_code: _status, body: body}}) do
    body_map = Poison.Parser.parse!(body)
    message = body_map["message"]
    {:ok, message}
  end

  defp handle_response({:error, %HTTPoison.Error{reason: reason}}) do
    {:error, reason}
  end

  # def query(id) do
  #   api_url(id)
  #   |> HTTPoison.get
  #   |> handle_response
  # end
  #
  # defp api_url(id) do
  #   "https://jsonplaceholder.typicode.com/users/#{URI.encode(id)}"
  # end
  #
  # defp handle_response({:ok, %{status_code: 200, body: body}}) do
  #   city =
  #     Poison.Parser.parse!(body, %{})
  #     |> get_in(["address", "city"])
  #
  #   {:ok, city}
  # end
  #
  # defp handle_response({:ok, %{status_code: _status, body: body}}) do
  #   message =
  #     Poison.Parser.parse!(body, %{})
  #     |> get_in(["message"])
  #
  #   {:error, message}
  # end
  #
  # defp handle_response({:error, %{reason: reason}}) do
  #   {:error, reason}
  # end
end

# case UserApi.query("1") do
#   {:ok, city} ->
#     city
#   {:error, error} ->
#     "Whoops! #{error}"
# end
