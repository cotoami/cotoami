defmodule Cotoami.CotonomaTest do
  use Cotoami.ModelCase

  alias Cotoami.Cotonoma

  @valid_attrs %{name: "cotonoma name", coto_id: "uuid", owner_id: "uuid"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Cotonoma.changeset_to_insert(%Cotonoma{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Cotonoma.changeset_to_insert(%Cotonoma{}, @invalid_attrs)
    refute changeset.valid?
  end
end
