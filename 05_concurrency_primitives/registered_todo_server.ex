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

defmodule TodoServer do
  def start do
    Process.register(self(), :todo_server)
    spawn(fn -> loop(TodoList.new) end)
  end
  
  def add_entry(new_entry) do
    send(:todo_server, {:add_entry, new_entry})
  end
  
  def entries(date) do
    send(:todo_server, {:entries, self(), date})
    
    receive do
      {:todo_entries, entries} -> entries
    after
      5000 -> {:error, :timeot}
    end
    
  end
  
  def update_entry(entry_id, updater_func) do
    send(:todo_server, {:update_entry, entry_id, updater_func})
  end
  
  def delete_entry(entry_id) do
    send(:todo_server, {:delete_entry, entry_id})
  end
  
  defp loop(todo_list) do
    new_todo_list =
      receive do
        message -> process_message(todo_list, message)
      end
    
    loop(new_todo_list)  
  end
  
  defp process_message(todo_list, {:add_entry, new_entry}) do
    TodoList.add_entry(todo_list, new_entry)
  end
  
  defp process_message(todo_list, {:entries, caller, date}) do
    send(caller, {:todo_entries, TodoList.entries(todo_list, date)})
    todo_list
  end
  
  defp process_message(todo_list, {:update_entry, entry_id, updater_func}) do
    TodoList.update_entry(todo_list, entry_id, updater_func)
  end
  
  defp process_message(todo_list, {:delete_entry, entry_id}) do
    TodoList.delete_entry(todo_list, entry_id)
  end
end
