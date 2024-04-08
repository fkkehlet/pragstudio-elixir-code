defmodule Servy.BearController do
  alias Servy.{Bear, Conv, View, Wildthings}
  # alias Servy.BearView
  # alias Servy.Conv
  # alias Servy.View, only: [render: 3]
  # alias Servy.Wildthings

  def index(%Conv{} = conv) do
    bears = Enum.sort(Wildthings.list_bears(), &Bear.order_asc_by_name/2)
    View.render(conv, "index.eex", bears: bears)
  end

  def show(%Conv{} = conv, %{"id" => id}) do
    bear = Wildthings.get_bear(id)
    View.render(conv, "show.eex", bear: bear)
  end

  # def index(%Conv{} = conv) do
  #   bears = Wildthings.list_bears() |> Enum.sort(&Bear.order_asc_by_name/2)
  #   %{conv | status: 200, resp_body: BearView.index(bears)}
  # end
  #
  # def show(%Conv{} = conv, %{"id" => id}) do
  #   bear = Wildthings.get_bear(id)
  #   %{conv | status: 200, resp_body: BearView.show(bear)}
  # end

  def create(%Conv{} = conv, %{"name" => name, "type" => type}) do
    %{conv | status: 201, resp_body: "Created a #{type} bear named #{name}!"}
  end

  def delete(%Conv{} = conv) do
    %{conv | status: 403, resp_body: "Bears must never be deleted!"}
  end
end
