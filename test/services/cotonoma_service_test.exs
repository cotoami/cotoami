defmodule Cotoami.CotonomaServiceTest do
  use Cotoami.DataCase
  import ShorterMaps

  alias Cotoami.EmailUser
  alias Cotoami.Amishi
  alias Cotoami.Coto
  alias Cotoami.Cotonoma
  alias Cotoami.CotonomaService
  alias Cotoami.AmishiService

  setup do
    amishi = AmishiService.insert_or_update!(%EmailUser{email: "amishi@example.com"})
    %{conn: Bolt.Sips.conn(), amishi: amishi}
  end

  test "creating a cotonoma in home", ~M{amishi} do
    cotonoma_coto = CotonomaService.create!("test", false, amishi)

    assert %Coto{
             content: "test",
             as_cotonoma: true,
             cotonoma: %Cotonoma{
               key: key,
               name: "test",
               shared: false,
               timeline_revision: 0,
               graph_revision: 0,
               last_post_timestamp: nil
             },
             repost: nil,
             posted_in: nil,
             amishi: %Amishi{email: "amishi@example.com"}
           } = cotonoma_coto

    assert String.length(key) == 16
  end
end
