defmodule Cotoami.AmishiService do
  @moduledoc """
  Provides Amishi related functions.
  """

  require Logger
  import Ecto.Changeset
  alias Cotoami.{Repo, Amishi, ExternalUser, EmailUser, GravatarService}

  def owner_emails do
    :cotoami
    |> Application.get_env(__MODULE__, [])
    |> Keyword.get(:owner_emails)
  end

  def get(id) do
    Amishi
    |> Repo.get(id)
    |> append_owner_flag()
  end

  def get_by_email(email) do
    Amishi
    |> Repo.get_by(email: email)
    |> append_owner_flag()
  end

  def insert_or_update_by_email!(email) do
    email
    |> GravatarService.get_user()
    |> insert_or_update!()
  end

  def accept_invite!(invitee_email, %Amishi{id: inviter_id}) do
    invitee_email
    |> insert_or_update_by_email!()
    |> change(inviter_id: inviter_id)
    |> Repo.update!()
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
