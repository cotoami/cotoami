defmodule Cotoami.AmishiService do
  @moduledoc """
  Provides Amishi related functions.
  """

  require Logger
  alias Cotoami.{Repo, Amishi, ExternalUser, EmailUser, GravatarService}

  def owner_emails do
    :cotoami
    |> Application.get_env(__MODULE__, [])
    |> Keyword.get(:owner_emails)
  end

  def signup_enabled do
    :cotoami
    |> Application.get_env(__MODULE__, [])
    |> Keyword.get(:signup_enabled)
  end

  def is_allowed_to_signin?(email) do
    signup_enabled() 
      || email in owner_emails() 
      || get_by_email(email)
  end

  def get(id) do
    Amishi
    |> Repo.get(id)
    |> append_owner_flag()
  end

  def get_by_email(email) do
    Repo.get_by(Amishi, email: email)
  end

  def insert_or_update_by_email!(email) do
    email
    |> GravatarService.get_user()
    |> insert_or_update!()
  end

  def insert_or_update!(base_user) do
    case get_by_base_user(base_user) do
      nil ->
        Amishi.changeset_to_insert(base_user)
        |> Repo.insert!()
      amishi ->
        Amishi.changeset_to_update(amishi, base_user)
        |> Repo.update!()
    end
  end

  defp get_by_base_user(%EmailUser{email: email}) do
    Repo.get_by(Amishi, email: email)
  end
  defp get_by_base_user(%ExternalUser{auth_provider: provider, auth_id: id}) do
    Repo.get_by(Amishi, auth_provider: provider, auth_id: id)
  end

  def append_owner_flag(nil), do: nil
  def append_owner_flag(%Amishi{} = amishi) do
    Map.put(amishi, :owner, amishi.email in owner_emails())
  end
end
