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

  describe "a coto pinned to an amishi" do
    setup ~M{conn, amishi} do
      {coto, _posted_in} = CotoService.create!(nil, amishi.id, "hello")
      CotoGraphService.pin(conn, coto, amishi)
      ~M{coto}
    end

    test "get", ~M{coto} do
      assert %Coto{
        content: "hello"
      } = CotoService.get(coto.id)
    end
  end
end
