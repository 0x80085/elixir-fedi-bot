defmodule Bot.Events do
  use Agent

  @max_entries 50

  defstruct exception_message: nil, date_time_occurred: nil, severity: nil

  # Start the Agent with an empty list as its initial state
  def start_link(_opts) do
    Agent.start_link(fn -> [] end, name: __MODULE__)
  end

  # Create a new event structure
  def new_event(exception_message, date_time_occurred, severity) do
    %__MODULE__{
      exception_message: exception_message,
      date_time_occurred: date_time_occurred,
      severity: severity
    }
  end

  # Add a new event to the managed list, keeping the list within @max_entries limit
  def add_event(event) when is_map(event) do
    Agent.update(__MODULE__, fn events ->
      updated_events =
        if length(events) >= @max_entries do
          List.delete_at(events, 0) ++ [event]
        else
          events ++ [event]
        end

      updated_events
    end)
  end

  # Retrieve the current list of events
  def get_events() do
    Agent.get(__MODULE__, fn events -> events end)
  end
end
