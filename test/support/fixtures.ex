defmodule Cotoami.Fixtures do
  alias Cotoami.Coto
  alias Cotoami.EmailUser
  alias Cotoami.AmishiService
  alias Cotoami.CotonomaService

  def create_amishi_with_email!(email) do
    AmishiService.insert_or_update!(%EmailUser{email: email})
  end

  def create_cotonoma!(amishi, name, shared, cotonoma_id \\ nil) do
    %Coto{cotonoma: cotonoma} = CotonomaService.create!(amishi, name, shared, cotonoma_id)
    cotonoma
  end
end
