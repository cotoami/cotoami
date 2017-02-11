defmodule Cotoami.MemberInheritanceTest do
  use Cotoami.ModelCase

  alias Cotoami.MemberInheritance

  @valid_attrs %{from_id: 1, to_id: 2}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = MemberInheritance.changeset(%MemberInheritance{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = MemberInheritance.changeset(%MemberInheritance{}, @invalid_attrs)
    refute changeset.valid?
  end
end
