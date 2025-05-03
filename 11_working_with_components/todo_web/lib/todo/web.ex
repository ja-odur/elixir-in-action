defmodule Todo.Web do
  use Plug.Router
  
  plug :match
  plug :dispatch
  
  post "/add_entry" do
    conn = Plug.Conn.fetch_query_params(conn)
    list_name = Map.fetch!(conn.params, "list")
    title = Map.fetch!(conn.params, "title")
    date = Date.from_iso8601!(Map.fetch!(conn.params, "date"))
    
    list_name
    |> Todo.Cache.server_process()
    |> Todo.Server.add_entry(%{title: title, date: date})
    
    conn
    |> Plug.conn.put_resp_content_type("text/plain")
    |> Plug.Conn.send_resp(200, "OK")
  end
  
  def child_spec(_args) do
    Plug.Cowboy.child_spec(
      scheme: :http,
      options: [port: 5454],
      plug: __MODULE__
    )
  end
end