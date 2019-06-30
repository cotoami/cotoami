defmodule Cotoami.CotoSearchServiceTest do
  use Cotoami.DataCase
  import ShorterMaps

  alias Cotoami.{
    Fixtures,
    Repo,
    EmailUser,
    Coto,
    AmishiService,
    CotoService,
    CotonomaService,
    CotoSearchService
  }

  setup do
    amishi_a = AmishiService.insert_or_update!(%EmailUser{email: "amishi_a@example.com"})
    amishi_b = AmishiService.insert_or_update!(%EmailUser{email: "amishi_b@example.com"})
    cotonoma_a = Fixtures.create_cotonoma!("cotonoma a", false, amishi_a)
    ~M{amishi_a, amishi_b, cotonoma_a}
  end

  describe "when there are private cotos by amishi_a" do
    setup ~M{amishi_a, cotonoma_a} do
      coto1 = Fixtures.create_coto!("Search has become an important feature.", amishi_a)
      coto2 = Fixtures.create_coto!("You are often asked to add search.", amishi_a, cotonoma_a)
      ~M{coto1, coto2}
    end

    test "amishi_a searches the cotos and finds a single result", ~M{amishi_a} do
      assert search(amishi_a, "important") == [
               "Search has become an important feature."
             ]
    end

    test "multiple results should be sorted in ascending order of date", ~M{amishi_a} do
      assert search(amishi_a, "search") == [
               "You are often asked to add search.",
               "Search has become an important feature."
             ]
    end

    test "amishi_b shouldn't be able to search the cotos", ~M{amishi_b} do
      assert search(amishi_b, "search") == []
    end
  end

  defp search(amishi, search_string) do
    Coto
    |> CotoSearchService.search(amishi, search_string)
    |> Repo.all()
    |> Enum.map(& &1.content)
  end
end
