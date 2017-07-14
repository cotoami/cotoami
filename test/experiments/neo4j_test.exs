defmodule Cotoami.Neo4jTest do
  use ExUnit.Case

  test "the truth" do
    assert 1 + 1 == 2
  end

  test "basic queries" do
    conn = Bolt.Sips.conn
    assert %{stats: %{"labels-added" => 1, "nodes-created" => 1, "properties-set" => 1}, type: "w"} =
      Bolt.Sips.query!(conn, "CREATE (a:Person {name:'Bob'})")
    assert [%{"name" => "Bob"}] =
      Bolt.Sips.query!(conn, "MATCH (a:Person {name: 'Bob'}) RETURN a.name AS name")
    assert %{stats: %{"nodes-deleted" => 1}, type: "w"} =
      Bolt.Sips.query!(conn, "MATCH (a:Person {name:'Bob'}) DELETE a")
  end
end
