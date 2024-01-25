defmodule Bot.RssRepo do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, warn: false

  schema "rss_urls" do
    field :is_enabled, :boolean, default: false
    field :url, :string
    field :hashtags, :string

    timestamps()
  end


  @spec changeset(
          {map, map}
          | %{
              :__struct__ => atom | %{:__changeset__ => map, optional(any) => any},
              optional(atom) => any
            },
          :invalid | %{optional(:__struct__) => none, optional(atom | binary) => any}
        ) :: Ecto.Changeset.t()
  @doc false
  def changeset(rss, attrs) do
    rss
    |> cast(attrs, [:url, :is_enabled])
    |> validate_required([:url, :is_enabled])
    |> unique_constraint(:url)
  end
end
