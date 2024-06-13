defmodule PostToApi do
  def post() do
    url = "https://jsonplaceholder.typicode.com/posts"
    body = ~s({"title": "New Pledge", "body": "Larry pledged $10"})
    # passing headers are optional
    headers = [{"Content-Type", "application/json"}]

    HTTPoison.post(url, body, headers)
    |> handle_response()
  end

  def handle_response({:ok, %HTTPoison.Response{status_code: 200, body: body}}) do

    {:ok, body}
  end
  def handle_response({:error, %HTTPoison.Error{reason: reason}}) do
    {:error, reason}
  end
end
