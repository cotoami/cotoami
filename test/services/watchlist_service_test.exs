defmodule Cotoami.WatchlistServiceTest do
  use Cotoami.ModelCase
  import ShorterMaps
  alias Cotoami.Fixtures
  alias Cotoami.Cotonoma
  alias Cotoami.Watching
  alias Cotoami.WatchlistService

  setup do
    amishi1 = Fixtures.create_amishi_with_email!("amishi1@example.com")
    amishi2 = Fixtures.create_amishi_with_email!("amishi2@example.com")
    shared_cotonoma1 = Fixtures.create_cotonoma!(amishi2, "shared cotonoma1", true)
    shared_cotonoma2 = Fixtures.create_cotonoma!(amishi2, "shared cotonoma2", true)
    ~M{amishi1, amishi2, shared_cotonoma1, shared_cotonoma2}
  end

  describe "when there is a watching" do
    setup ~M{amishi1, shared_cotonoma1} do
      watching = WatchlistService.get_or_create!(amishi1, shared_cotonoma1)
      ~M{watching}
    end

    test "it should be contained in the watchlist", ~M{amishi1} do
      assert [
        %Watching{
          amishi: %Ecto.Association.NotLoaded{},
          cotonoma: %Cotonoma{name: "shared cotonoma1"},
          last_post_timestamp: nil
        }
      ] = WatchlistService.get_watchlist(amishi1)
    end

    test "amishi1 adds a watching", ~M{amishi1, shared_cotonoma2} do
      WatchlistService.get_or_create!(amishi1, shared_cotonoma2)
      assert [
        %Watching{
          amishi: %Ecto.Association.NotLoaded{},
          cotonoma: %Cotonoma{name: "shared cotonoma2"},
          last_post_timestamp: nil
        },
        %Watching{
          amishi: %Ecto.Association.NotLoaded{},
          cotonoma: %Cotonoma{name: "shared cotonoma1"},
          last_post_timestamp: nil
        }
      ] = WatchlistService.get_watchlist(amishi1)
    end
  end
end

