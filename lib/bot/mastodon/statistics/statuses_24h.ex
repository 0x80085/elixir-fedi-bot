defmodule Bot.Mastodon.Statistics.Statuses24h do
  def get() do
    get_statuses_recursive([], nil)
  end

  defp get_statuses_recursive(statuses, max_id) do
    case get_statuses_page(max_id) do
      {:ok, new_statuses} ->
        case Enum.find_index(new_statuses, &is_old_status/1) do
          nil ->
            case Enum.take_while(new_statuses, &is_recent_status/1) do
              [] ->
                {statuses, :done}

              recent_statuses ->
                last_id = recent_statuses |> List.last() |> Map.get("id")
                get_statuses_recursive(statuses ++ recent_statuses, last_id)
            end

          index ->
            {statuses ++ Enum.take(new_statuses, index), :done}
        end

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp get_statuses_page(max_id) do
    credentials = Bot.Mastodon.Auth.PersistCredentials.get_credentials()
    token = credentials.user_token
    account_id = credentials.account_id
    fedi_url = credentials.fedi_url

    headers = [{"Authorization", "Bearer #{token}"}]

    query_params = %{
      "max_id" => max_id,
      "limit" => 40
    }

    query_string = URI.encode_query(query_params)

    url = "#{fedi_url}/api/v1/accounts/#{account_id}/statuses?#{query_string}"

    HTTPoison.get(url, headers)
    |> handle_response()
  end

  defp is_recent_status(status) do
    now = Timex.now()

    case Timex.parse(status["created_at"], "{ISO:Extended}") do
      {:ok, created_at} ->
        is_within_24h = Timex.diff(now, created_at, :seconds) < 86400
        is_within_24h

      _ ->
        false
    end
  end

  defp is_old_status(status) do
    now = Timex.now()

    case Timex.parse(status["created_at"], "{ISO:Extended}") do
      {:ok, created_at} ->
        is_older_than_24h = Timex.diff(now, created_at, :seconds) >= 86400
        is_older_than_24h

      _ ->
        false
    end
  end

  defp handle_response({:ok, %HTTPoison.Response{status_code: 200, body: body}}) do
    {:ok, Jason.decode!(body)}
  end

  defp handle_response({_, %HTTPoison.Response{status_code: code, body: body}}) do
    {:error, "HTTP request failed with status code #{code}: #{body}"}
  end

  defp handle_response({:error, reason}), do: {:error, "HTTP request failed: #{reason}"}
end
