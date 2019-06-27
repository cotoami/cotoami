defmodule Cotoami.CotoServiceTest do
  use Cotoami.DataCase
  import ShorterMaps

  alias Cotoami.{
    Fixtures,
    EmailUser,
    Amishi,
    Coto,
    Cotonoma,
    AmishiService,
    CotoService,
    CotoGraphService
  }

  setup do
    amishi = AmishiService.insert_or_update!(%EmailUser{email: "amishi@example.com"})
    %{conn: Bolt.Sips.conn(), amishi: amishi}
  end

  test "creating a coto without content", ~M{amishi} do
    coto = CotoService.create!(nil, nil, amishi)
    assert %Coto{content: ""} = CotoService.get(coto.id)
  end

  describe "when there is a coto" do
    setup ~M{amishi} do
      coto = Fixtures.create_coto!("hello", amishi)
      ~M{coto}
    end

    test "the coto can be gotten by id", ~M{coto} do
      assert %Coto{content: "hello"} = CotoService.get(coto.id)
    end

    test "reposting it to another cotonoma", ~M{amishi, coto} do
      cotonoma = Fixtures.create_cotonoma!("test", false, amishi)
      %Cotonoma{id: cotonoma_id} = cotonoma

      repost = CotoService.repost!(coto, amishi, cotonoma)

      # repost container
      assert %Coto{
               content: "",
               as_cotonoma: false,
               repost: %Coto{content: "hello"},
               posted_in: %Cotonoma{name: "test"},
               amishi: %Amishi{email: "amishi@example.com"}
             } = repost

      # reposted coto
      assert %Coto{
               content: "hello",
               posted_in: nil,
               reposted_in_ids: [^cotonoma_id]
             } = CotoService.get(coto.id)
    end
  end

  describe "when there is a cotonoma" do
    setup ~M{amishi} do
      cotonoma = Fixtures.create_cotonoma!("test", false, amishi)
      ~M{cotonoma}
    end

    test "posting a coto to it", ~M{amishi, cotonoma} do
      assert cotonoma.timeline_revision == 0

      coto = CotoService.create!("hello", nil, amishi, cotonoma)
      assert coto.content == "hello"
      assert coto.posted_in.id == cotonoma.id

      cotonoma = Repo.get!(Cotonoma, cotonoma.id)
      assert cotonoma.timeline_revision == 1
      assert cotonoma.last_post_timestamp == coto.inserted_at
    end
  end

  describe "when there are various cotos" do
    setup ~M{conn, amishi} do
      cotonoma = Fixtures.create_cotonoma!("test", false, amishi)

      coto1 = Fixtures.create_coto!("coto1", amishi)
      coto2 = Fixtures.create_coto!("coto2", amishi)
      CotoGraphService.pin(conn, coto2, nil, amishi)
      coto3 = Fixtures.create_coto!("coto3", amishi)
      CotoGraphService.connect(conn, coto2, coto3, nil, amishi)
      coto4 = Fixtures.create_coto!("coto4", amishi, cotonoma)

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
