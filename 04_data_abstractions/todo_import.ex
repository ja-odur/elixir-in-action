defmodule TodoList do
  defstruct next_id: 1, entries: %{}
  
  def new(entries \\ []) do
    Enum.reduce(
      entries,
      %TodoList{},
      # fn entry, todo_list_acc -> add_entry(todo_list_acc, entry) end,
      &add_entry(&2, &1)
    )
  end
  
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

defmodule TodoList.CsvImporter do
  def import(file_name) do
    file_name
    |> read_lines
    |> create_entries
    |> TodoList.new()
  end
  
  def read_lines(file_name) do
    file_name
    |> File.stream!()
    |> Stream.map(&String.trim_trailing(&1, "\n"))
  end
  
  def create_entries(lines) do
    Stream.map(
      lines,
      fn line ->
       [date_string, title] = String.split(line, ",")
       date = Date.from_iso8601!(date_string)
       %{date: date, title: title}
      end
    )
  end
end

defimpl Collectable, for: TodoList  do
  def into(original) do
    {original, &into_callback/2}
  end
  
  defp into_callback(todo_list, {:cont, entry}) do
    TodoList.add_entry(todo_list, entry)
  end
  
  defp into_callback(todo_list, :done), do: todo_list
  
  defp into_callback(_todo_list, :halt), do: :ok
end