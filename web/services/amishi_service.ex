defmodule Cotoami.AmishiService do
  require Logger
  alias Cotoami.Repo
  alias Cotoami.Amishi
  
  def get(id) do
    Amishi |> Repo.get(id)
  end
  
  def get_by_email(email) do
    Amishi |> Repo.get_by(email: email)
  end
  
  def create(email) do
    changeset = Amishi.changeset(%Amishi{}, %{email: email})
    Repo.insert!(changeset)
  end
end
