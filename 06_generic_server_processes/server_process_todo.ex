defmodule TodoList do
  defstruct next_id: 1, entries: %{}
  
  def new(), do: %TodoList{}
  
  def add_entry(todo_list, entry) do
    entry = Map.put(entry, :id, todo_list.next_id)
    
    new_entries = Map.put(
      todo_list.entries,
      todo_list.next_id,
      entry
    )
    
    %TodoList{
      todo_list |
      entries: new_entries,
      next_id: todo_list.next_id + 1
    }
  end
  
  def entries(todo_list, date) do
    todo_list.entries
    |> Map.values()
    |> Enum.filter(fn entry -> entry.date == date end)
  end
  
  def update_entry(todo_list, entry_id, updater_func) do
    case Map.fetch(todo_list.entries, entry_id) do
      :error -> todo_list
      {:ok, old_entry} ->
        new_entry = updater_func.(old_entry)
        new_entries = Map.put(todo_list.entries, new_entry.id, new_entry)
        %TodoList{todo_list | entries: new_entries}
    end
  end
  
  def delete_entry(todo_list, entry_id) do
    new_entries = Map.delete(todo_list.entries, entry_id)
    %TodoList{todo_list | entries: new_entries}
  end
  
end

defmodule ServerProcess do
  def start(callback_module) do
    spawn(fn ->
      initial_state = callback_module.init()
      loop(callback_module, initial_state)
      end)
  end
  
  defp loop(callback_module, current_state) do
    receive do
      {:call, request, caller} ->
        {response, new_state} = 
          callback_module.handle_call(
            request, 
            current_state
          )
          
        send(caller, {:response, response})
        loop(callback_module, new_state)
      
      {:cast, request} ->
        new_state =
          callback_module.handle_cast(
            request, 
            current_state
          )
          
        loop(callback_module, new_state)
    end
  end
  
  def call(server_pid, request) do
    send(server_pid, {:call, request, self()})
  end
  
  def cast(server_pid, request) do
    send(server_pid, {:cast, request})
  end
end

defmodule TodoServer do
  alias Task.Supervised
  def start do
    ServerProcess.start(TodoServer)
  end
  
  def add_entry(todo_server, new_entry) do
    ServerProcess.cast(todo_server, {:add_entry, new_entry})
  end
  
  def entries(todo_server, date) do
    ServerProcess.call(todo_server, {:entries, date})
  end
  
  def init do
    TodoList.new()
  end
  
  def handle_cast({:add_entry, new_entry}, todo_list) do
    TodoList.add_entry(todo_list, new_entry)
  end
  
  def handle_call({:entries, date}, todo_list) do
    {TodoList.entries(todo_list, date), todo_list}
  end
end