defmodule Cotoami.CotonomaTest do
  use Cotoami.ModelCase

  alias Cotoami.Cotonoma

  @valid_attrs %{key: "some content", name: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Cotonoma.changeset(%Cotonoma{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Cotonoma.changeset(%Cotonoma{}, @invalid_attrs)
    refute changeset.valid?
  end
end
