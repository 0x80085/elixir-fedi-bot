defmodule Bot.Settings do
  use Ecto.Schema
  import Ecto.Changeset

  schema "settings" do
    field(:key, :string)
    field(:value, :string)

    timestamps()
  end

  @doc false
  def changeset(settings, attrs) do
    settings
    |> cast(attrs, [:key, :value])
    |> validate_required([:key, :value])
  end

  def is_supported_setting_key(key) do
    # todo add to above changeset func
    case key in [
           "is_dry_run",
           "max_post_burst_amount",
           "rss_scrape_max_age_in_s",
           "rss_scrape_interval_in_ms"
         ] do
      true ->
        nil

      _ ->
        nil
    end
  end
end
