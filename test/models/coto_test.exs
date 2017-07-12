defmodule Cotoami.CotoTest do
  use Cotoami.ModelCase

  alias Cotoami.Coto

  @valid_attrs %{posted_in_id: "uuid", amishi_id: "uuid", content: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Coto.changeset(%Coto{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Coto.changeset(%Coto{}, @invalid_attrs)
    refute changeset.valid?
  end
end
