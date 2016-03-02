defmodule Todo.List do
  defstruct auto_id: 1, entries: HashDict.new

  def new, do: %Todo.List{}

  def add_entry(%Todo.List{entries: entries, auto_id: auto_id} = todo_list, entry) do
    entry = Map.put(entry, :id, auto_id)
    new_entries = HashDict.put(entries, auto_id, entry)
    %Todo.List{ todo_list | entries: new_entries, auto_id: auto_id + 1  }
  end

  def entries(%Todo.List{entries: entries}, date) do
    entries
    |> Stream.filter(fn({_, entry}) -> entry.date == date end)
    |> Enum.filter(fn({_, entry}) -> entry end)
  end
end


