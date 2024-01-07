defmodule Bot.Events do
  use Agent

  @max_entries 50

  defstruct message: nil, date_time_occurred: nil, severity: nil

  # Start the Agent with an empty list as its initial state
  def start_link(_opts) do
    Agent.start_link(fn -> [] end, name: __MODULE__)
  end

  # Create a new event structure
  def new_event(message, severity) do
    %__MODULE__{
      message: message,
      date_time_occurred: DateTime.utc_now(),
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
    Agent.get(__MODULE__, fn events ->
      Enum.map(events, fn it ->
        %{
          "severity" => it.severity,
          "date_time_occurred" => it.date_time_occurred,
          "message" => it.message
        }
      end)
      |> Enum.sort(&DateTime.compare(&1["date_time_occurred"], &2["date_time_occurred"]) == :gt)
    end)
  end
end
