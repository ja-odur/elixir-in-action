defmodule Todo.Server do
  use GenServer, restart: :temporary
  
  @expiry_idle_timeout :timer.seconds(10)
  
  def start_link(name) do
    GenServer.start_link(Todo.Server, name, name: via_tuple(name))
  end
  
  def via_tuple(key) do
    Todo.ProcessRegistry.via_tuple({__MODULE__, key})
  end
  
  def add_entry(todo_server, new_entry) do
    GenServer.cast(todo_server, {:add_entry, new_entry})
  end
  
  def entries(todo_server, date) do
    GenServer.call(todo_server, {:entries, date})
  end
  
  @impl GenServer
  def init(name) do
    {:ok, {name, nil}, {:continue, :init}}
  end
  
  @impl GenServer
  def handle_continue(:init, {name, nil}) do
    todo_list = Todo.Database.get(name) || Todo.List.new()
    {
      :noreply, 
      {name, todo_list},
      @expiry_idle_timeout
    }
  end
  
  @impl GenServer
  def handle_cast({:add_entry, new_entry}, {name, todo_list}) do
    new_list = Todo.List.add_entry(todo_list, new_entry)
    Todo.Database.store(name, new_list)
    {:noreply, {name, new_list}, @expiry_idle_timeout}
  end
  
  @impl GenServer
  def handle_call({:entries, date}, _, {name, todo_list}) do
    {
      :reply,
      Todo.List.entries(todo_list, date),
      {name, todo_list},
      @expiry_idle_timeout
    }
  end
  
  @impl GenServer
  def handle_info(:timeout, {name, todo_list}) do
    IO.puts("Stopping to-do list server for #{name}")
    {:stop, :normal, {name, todo_list}}
  end
end