defmodule Cotoami.CotonomaServiceTest do
  use Cotoami.DataCase
  import ShorterMaps

  alias Cotoami.Fixtures
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

  describe "when there is a cotonoma" do
    setup ~M{amishi} do
      cotonoma = Fixtures.create_cotonoma!("test", false, amishi)
      ~M{cotonoma}
    end

    test "get_accessible_by_key_or_name", ~M{amishi, cotonoma} do
      assert CotonomaService.get_accessible_by_key_or_name("no-such-cotonoma", amishi) == nil
      assert CotonomaService.get_accessible_by_key_or_name("test", amishi).id == cotonoma.id
      assert CotonomaService.get_accessible_by_key_or_name(cotonoma.key, amishi).id == cotonoma.id
    end
  end
end
