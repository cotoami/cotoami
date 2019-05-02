defmodule Cotoami.CotoServiceTest do
  use Cotoami.DataCase
  import ShorterMaps

  alias Cotoami.{
    EmailUser,
    Coto,
    AmishiService,
    CotoService,
    CotonomaService,
    CotoGraphService
  }

  setup do
    amishi = AmishiService.insert_or_update!(%EmailUser{email: "amishi@example.com"})
    %{conn: Bolt.Sips.conn(), amishi: amishi}
  end

  describe "when there is a coto" do
    setup ~M{amishi} do
      coto = CotoService.create!(amishi, "hello")
      ~M{coto}
    end

    test "the coto can be gotten by id", ~M{coto} do
      assert %Coto{content: "hello"} = CotoService.get(coto.id)
    end
  end

  describe "when there is a cotonoma" do
    setup ~M{amishi} do
      %Coto{cotonoma: cotonoma} = CotonomaService.create!(amishi, "test", false)
      ~M{cotonoma}
    end

    test "posting a coto to it", ~M{amishi, cotonoma} do
      assert cotonoma.timeline_revision == 0

      coto = CotoService.create!(amishi, "hello", nil, cotonoma.id)
      assert coto.content == "hello"
      assert coto.posted_in.id == cotonoma.id

      cotonoma = CotonomaService.get(cotonoma.id)
      assert cotonoma.timeline_revision == 1
      assert cotonoma.last_post_timestamp == coto.inserted_at
    end
  end

  describe "when there are various cotos" do
    setup ~M{conn, amishi} do
      %Coto{cotonoma: cotonoma} = CotonomaService.create!(amishi, "test", false)

      coto1 = CotoService.create!(amishi, "coto1")
      coto2 = CotoService.create!(amishi, "coto2")
      CotoGraphService.pin(conn, coto2, nil, amishi)
      coto3 = CotoService.create!(amishi, "coto3")
      CotoGraphService.connect(conn, coto2, coto3, nil, amishi)
      coto4 = CotoService.create!(amishi, "coto4", nil, cotonoma.id)

      ~M{cotonoma, coto1, coto2, coto3, coto4}
    end

    test "all_by_amishi should return all by default", ~M{amishi} do
      assert [
               %Coto{content: "coto4"},
               %Coto{content: "coto3"},
               %Coto{content: "coto2"},
               %Coto{content: "coto1"},
               %Coto{content: "test", as_cotonoma: true}
             ] = CotoService.all_by_amishi(amishi, 0).rows
    end

    test "all_by_cotonoma", ~M{amishi, cotonoma} do
      assert [
               %Coto{content: "coto4"}
             ] = CotoService.all_by_cotonoma(cotonoma, amishi, 0).rows
    end

    test "all_by_amishi with :exclude_pinned_graph", ~M{amishi} do
      assert [
               %Coto{content: "coto4"},
               %Coto{content: "coto1"},
               %Coto{content: "test", as_cotonoma: true}
             ] = CotoService.all_by_amishi(amishi, 0, exclude_pinned_graph: true).rows
    end

    test "all_by_amishi with :exclude_posts_in_cotonoma", ~M{amishi} do
      assert [
               %Coto{content: "coto3"},
               %Coto{content: "coto2"},
               %Coto{content: "coto1"},
               %Coto{content: "test", as_cotonoma: true}
             ] = CotoService.all_by_amishi(amishi, 0, exclude_posts_in_cotonoma: true).rows
    end

    test "all_by_amishi with :exclude_pinned_graph and :exclude_posts_in_cotonoma", ~M{amishi} do
      assert [
               %Coto{content: "coto1"},
               %Coto{content: "test", as_cotonoma: true}
             ] =
               CotoService.all_by_amishi(
                 amishi,
                 0,
                 exclude_pinned_graph: true,
                 exclude_posts_in_cotonoma: true
               ).rows
    end
  end
end
