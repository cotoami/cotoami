defmodule Cotoami.WatchServiceTest do
  use Cotoami.DataCase
  import ShorterMaps

  alias Cotoami.{
    Fixtures,
    Cotonoma,
    Watch,
    WatchService
  }

  setup do
    amishi1 = Fixtures.create_amishi_with_email!("amishi1@example.com")
    amishi2 = Fixtures.create_amishi_with_email!("amishi2@example.com")
    shared_cotonoma1 = Fixtures.create_cotonoma!("shared cotonoma1", true, amishi2)
    shared_cotonoma2 = Fixtures.create_cotonoma!("shared cotonoma2", true, amishi2)
    ~M{amishi1, amishi2, shared_cotonoma1, shared_cotonoma2}
  end

  describe "when there is a watch" do
    setup ~M{amishi1, shared_cotonoma1} do
      watch = WatchService.get_or_create!(amishi1, shared_cotonoma1)
      ~M{watch}
    end

    test "it should be contained in the watchlist", ~M{amishi1} do
      assert [
               %Watch{
                 amishi: %Ecto.Association.NotLoaded{},
                 cotonoma: %Cotonoma{name: "shared cotonoma1"},
                 last_post_timestamp: nil
               }
             ] = WatchService.get_watchlist(amishi1)
    end

    test "amishi1 adds a watch", ~M{amishi1, shared_cotonoma2} do
      WatchService.get_or_create!(amishi1, shared_cotonoma2)

      assert [
               %Watch{
                 amishi: %Ecto.Association.NotLoaded{},
                 cotonoma: %Cotonoma{name: "shared cotonoma2"},
                 last_post_timestamp: nil
               },
               %Watch{
                 amishi: %Ecto.Association.NotLoaded{},
                 cotonoma: %Cotonoma{name: "shared cotonoma1"},
                 last_post_timestamp: nil
               }
             ] = WatchService.get_watchlist(amishi1)
    end
  end
end
