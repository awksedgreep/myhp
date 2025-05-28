defmodule Myhp.Contact.ContactMessage do
  use Ecto.Schema
  import Ecto.Changeset

  schema "contact_messages" do
    field :message, :string
    field :name, :string
    field :read, :boolean, default: false
    field :email, :string
    field :subject, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(contact_message, attrs) do
    contact_message
    |> cast(attrs, [:name, :email, :subject, :message, :read])
    |> validate_required([:name, :email, :subject, :message])
    |> validate_length(:name, min: 2, max: 100)
    |> validate_length(:subject, min: 5, max: 200)
    |> validate_length(:message, min: 10, max: 2000)
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must be a valid email")
    |> validate_email_mx()
  end

  defp validate_email_mx(changeset) do
    validate_change(changeset, :email, fn :email, email ->
      # Basic domain validation - in production you might want more sophisticated checks
      case String.split(email, "@") do
        [_local, domain] when byte_size(domain) > 3 -> []
        _ -> [email: "must have a valid domain"]
      end
    end)
  end
end
