defmodule Bot.RSS.FoundUrlArchive do
  use Agent

  @default_state %{
    entries: []
  }

  def start_link(_opts) do
    Agent.start_link(
      fn ->
        @default_state
      end,
      name: __MODULE__
    )
  end

  def get_entry_by_id(id) do
    Agent.get(__MODULE__, fn state ->
      Enum.find(state.entries, nil, fn it -> it.id == id end)
    end)
  end

  def exists(id) do
    Agent.get(__MODULE__, fn state ->
      Enum.any?(state.entries, fn it -> it.id == id end)
    end)
  end

  def add_entry_id(entry_id) do
    Agent.update(__MODULE__, fn state ->
      %{
        entries: Enum.concat([state.entries, [%{id: entry_id}]])
      }
    end)
  end
end
