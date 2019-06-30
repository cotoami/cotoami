defmodule Cotoami.CotoSearchServiceTest do
  use Cotoami.DataCase
  import ShorterMaps

  alias Cotoami.{
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
    %Coto{cotonoma: cotonoma_a} = CotonomaService.create!("cotonoma a", false, amishi_a)
    ~M{amishi_a, amishi_b, cotonoma_a}
  end

  describe "when there are private cotos by amishi_a" do
    setup ~M{amishi_a, cotonoma_a} do
      CotoService.create!("Search has become an important feature.", nil, amishi_a)
      CotoService.create!("You are often asked to add search.", nil, amishi_a, cotonoma_a)
      :ok
    end

    test "one coto can be searched by amishi_a", ~M{amishi_a} do
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

    test "no cotos can be searched by amishi_b", ~M{amishi_b} do
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
