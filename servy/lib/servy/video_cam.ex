defmodule Servy.VideoCam do
  @doc """
  Simulates sending a request to an external API
  to get a snapshot image from a video camera.
  """
  def get_snapshot(caller, camera_name) do
    spawn(fn ->
      # SEND REQUEST TO EXTERNAL API HERE

      # Sleep for 1 second to simulate that the API can be slow
      :timer.sleep(1000)

      # Example response returned from the API:
      response = "#{camera_name}-snapshot.jpg"

      send(caller, {:result, response})
    end)
  end
end
