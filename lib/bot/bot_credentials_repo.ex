defmodule Bot.BotCredentialsRepo do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, warn: false

  schema "bot_credentials" do
    field :account_id, :string
    field :app_token, :string
    field :client_id, :string
    field :client_secret, :string
    field :fedi_url, :string
    field :user_token, :string
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
  def changeset(creds, attrs) do
    creds
    |> cast(attrs, [:account_id, :app_token, :client_id, :client_secret, :fedi_url, :user_token])
    |> validate_required([
      :account_id,
      :app_token,
      :client_id,
      :client_secret,
      :fedi_url,
      :user_token
    ])
  end

end
