defmodule Servy.PledgeController do
  alias Servy.{Conv, PledgeServer, View}

  def create(%Conv{} = conv, %{"name" => name, "amount" => amount}) do
    # Sends the pledge to the external service and caches it
    PledgeServer.create_pledge(name, String.to_integer(amount))

    %{conv | status: 201, resp_body: "#{name} pledged #{amount}!"}
  end

  def index(%Conv{} = conv) do
    # Gets the recent pledges from the cache
    pledges = PledgeServer.recent_pledges()

    View.render(conv, "recent_pledges.eex", pledges: pledges)
  end

  def new(%Conv{} = conv) do
    View.render(conv, "new_pledge.eex")
  end

end
