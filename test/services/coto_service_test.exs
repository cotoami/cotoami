defmodule Cotoami.CotoServiceTest do
  use Cotoami.ModelCase
  import ShorterMaps
  alias Cotoami.{
    CotoService, AmishiService, CotoGraphService, Coto
  }

  setup do
    amishi = AmishiService.create!("amishi@example.com")
    %{conn: Bolt.Sips.conn, amishi: amishi}
  end

  describe "when there is a coto pinned to an amishi" do
    setup ~M{conn, amishi} do
      {coto, _posted_in} = CotoService.create!(amishi, "hello")
      CotoGraphService.pin(conn, coto, amishi)
      ~M{coto}
    end

    test "the coto can be gotten", ~M{coto} do
      assert %Coto{content: "hello"} = CotoService.get(coto.id)
    end
  end
end
