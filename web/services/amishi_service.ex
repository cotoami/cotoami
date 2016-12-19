defmodule Cotoami.AmishiService do
  require Logger
  alias Cotoami.Repo
  alias Cotoami.Amishi
  
  def get_amishi_by_email(email) do
    Repo.get_by(Amishi, email: email)
  end
  
  def create_amishi(email) do
    changeset = Amishi.changeset(%Amishi{}, %{email: email})
    Repo.insert!(changeset)
  end
end
