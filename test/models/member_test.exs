defmodule Cotoami.MemberTest do
  use Cotoami.ModelCase

  alias Cotoami.Member

  @valid_attrs %{email: "some content", cotonoma_id: "uuid"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Member.changeset(%Member{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Member.changeset(%Member{}, @invalid_attrs)
    refute changeset.valid?
  end
end
