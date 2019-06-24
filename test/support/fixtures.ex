defmodule Cotoami.Fixtures do
  alias Cotoami.Coto
  alias Cotoami.EmailUser
  alias Cotoami.AmishiService
  alias Cotoami.CotonomaService

  def create_amishi_with_email!(email) do
    AmishiService.insert_or_update!(%EmailUser{email: email})
  end

  def create_cotonoma!(name, shared, amishi) do
    %Coto{cotonoma: cotonoma} = CotonomaService.create!(name, shared, amishi)
    cotonoma
  end
end
