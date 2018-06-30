defmodule Cotoami.CotoServiceTest do
  use Cotoami.ModelCase
  import ShorterMaps
  alias Cotoami.{
    AmishiService, CotoService, CotonomaService, CotoGraphService, Coto
  }

  setup do
    amishi = AmishiService.create!("amishi@example.com")
    %{conn: Bolt.Sips.conn, amishi: amishi}
  end

  describe "when there is a coto pinned to an amishi" do
    setup ~M{conn, amishi} do
      {coto, _} = CotoService.create!(amishi, "hello")
      CotoGraphService.pin(conn, coto, amishi)
      ~M{coto}
    end

    test "the coto can be gotten", ~M{coto} do
      assert %Coto{content: "hello"} = CotoService.get(coto.id)
    end
  end

  describe "when there are various cotos" do
    setup ~M{conn, amishi} do
      {%Coto{cotonoma: cotonoma}, _} = CotonomaService.create!(amishi, "test")

      {coto1, _} = CotoService.create!(amishi, "coto1")
      {coto2, _} = CotoService.create!(amishi, "coto2")
      CotoGraphService.pin(conn, coto2, amishi)
      {coto3, _} = CotoService.create!(amishi, "coto3")
      CotoGraphService.connect(conn, coto2, coto3, amishi)
      {coto4, _} = CotoService.create!(amishi, "coto4", nil, cotonoma.id)

      ~M{cotonoma, coto1, coto2, coto3, coto4}
    end

    test "get_cotos_by_amishi should return all by default", ~M{amishi} do
      assert [
        %Coto{content: "coto4"},
        %Coto{content: "coto3"},
        %Coto{content: "coto2"},
        %Coto{content: "coto1"},
        %Coto{content: "test", as_cotonoma: true}
      ] = CotoService.get_cotos_by_amishi(amishi, 0).rows
    end

    test "get_cotos_by_cotonoma", ~M{amishi, cotonoma} do
      assert [
        %Coto{content: "coto4"}
      ] = CotoService.get_cotos_by_cotonoma(cotonoma.key, amishi, 0).rows
    end

    test "get_cotos_by_amishi with :exclude_pinned_graph", ~M{amishi} do
      assert [
        %Coto{content: "coto4"},
        %Coto{content: "coto1"},
        %Coto{content: "test", as_cotonoma: true}
      ] = CotoService.get_cotos_by_amishi(amishi, 0, exclude_pinned_graph: true).rows
    end

    test "get_cotos_by_amishi with :exclude_posts_in_cotonoma", ~M{amishi} do
      assert [
        %Coto{content: "coto3"},
        %Coto{content: "coto2"},
        %Coto{content: "coto1"},
        %Coto{content: "test", as_cotonoma: true}
      ] = CotoService.get_cotos_by_amishi(amishi, 0, exclude_posts_in_cotonoma: true).rows
    end

    test "get_cotos_by_amishi with :exclude_pinned_graph and :exclude_posts_in_cotonoma", ~M{amishi} do
      assert [
        %Coto{content: "coto1"},
        %Coto{content: "test", as_cotonoma: true}
      ] = CotoService.get_cotos_by_amishi(amishi, 0, 
        exclude_pinned_graph: true, 
        exclude_posts_in_cotonoma: true
      ).rows
    end
  end
end
