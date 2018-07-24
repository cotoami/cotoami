defmodule Cotoami.CotoSearchServiceTest do
  use Cotoami.ModelCase
  import ShorterMaps
  alias Cotoami.{
    Repo, Coto,
    AmishiService, CotoService, CotonomaService, CotoSearchService
  }

  setup do
    amishi_a = AmishiService.create!("amishi_a@example.com")
    amishi_b = AmishiService.create!("amishi_b@example.com")
    {%Coto{cotonoma: cotonoma}, _} = CotonomaService.create!(amishi_b, "cotonoma", false)
    ~M{amishi_a, amishi_b, cotonoma}
  end

  describe "when there are private cotos by amishi_a" do
    setup ~M{amishi_a} do
      CotoService.create!(amishi_a, "Search has become an important feature.")
      CotoService.create!(amishi_a, "You are often asked to add search.")
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

  describe "when there are cotos by amishi_b" do
    setup ~M{amishi_b, cotonoma} do
      CotoService.create!(amishi_b, "Search has become an important feature.")
      CotoService.create!(amishi_b, "You are often asked to add search.", nil, cotonoma.id)
      :ok
    end

    test "cotos in a cotonoma can be searched by other amishis", ~M{amishi_a} do
      assert search(amishi_a, "search") == [
        "You are often asked to add search."
      ]
    end
  end

  defp search(amishi, search_string) do
    Coto
    |> CotoSearchService.search(amishi, search_string)
    |> Repo.all()
    |> Enum.map(&(&1.content))
  end
end

