defmodule MyhpWeb.PageController do
  use MyhpWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
