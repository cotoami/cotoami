defmodule Cotoami.CotonomaTest do
  use Cotoami.ModelCase

  alias Cotoami.Cotonoma

  @valid_attrs %{owner_id: 1, name: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Cotonoma.changeset_new(%Cotonoma{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Cotonoma.changeset_new(%Cotonoma{}, @invalid_attrs)
    refute changeset.valid?
  end
end
