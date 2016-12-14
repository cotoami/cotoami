defmodule Cotoami.AmishiTest do
  use Cotoami.ModelCase

  alias Cotoami.Amishi

  @valid_attrs %{email: "test@example.com"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Amishi.changeset(%Amishi{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Amishi.changeset(%Amishi{}, @invalid_attrs)
    refute changeset.valid?
  end
end
