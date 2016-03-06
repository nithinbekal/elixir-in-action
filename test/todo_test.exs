defmodule TodoTest do
  use ExUnit.Case
  doctest Todo

  test "it works" do
    {:ok, cache} = Todo.Cache.start
    bobs_list = Todo.Cache.server_process(cache, "bobs_list")
    Todo.Server.clear(bobs_list)
    Todo.Server.add_entry(bobs_list, %{date: {2013, 12, 19}, title: "Dentist"})

    entries = Todo.Server.entries(bobs_list, {2013, 12, 19})
    assert entries == [{1, %{date: {2013, 12, 19}, id: 1, title: "Dentist"}}]
  end
end
