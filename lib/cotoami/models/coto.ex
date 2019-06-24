defmodule Cotoami.Coto do
  @moduledoc """
  コト (Coto) is a post by an Amishi.
  """

  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, warn: false
  import Cotoami.Helpers
  alias Cotoami.Amishi
  alias Cotoami.Coto
  alias Cotoami.Cotonoma

  @summary_max_length 200
  @content_max_length 2500

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "cotos" do
    field(:content, :string)
    field(:long_content, :string)
    field(:summary, :string)
    field(:as_cotonoma, :boolean)
    belongs_to(:posted_in, Cotonoma)
    belongs_to(:amishi, Amishi)
    has_one(:cotonoma, Cotonoma)

    belongs_to(:repost, Coto)
    field(:reposted_in_ids, {:array, Ecto.UUID})

    timestamps(type: :utc_datetime)
  end

  def changeset_to_insert(params \\ %{}) do
    %Coto{}
    |> cast(params, [:content, :summary, :as_cotonoma, :posted_in_id, :amishi_id])
    |> validate_required([:amishi_id])
    |> validate_length(:summary, max: @summary_max_length)
    |> normalize_no_content()
    |> store_long_content()
  end

  def changeset_to_repost(
        %Coto{id: coto_id, repost: nil},
        %Amishi{id: amishi_id},
        cotonoma_id \\ nil
      ) do
    %Coto{}
    |> change(
      repost_id: coto_id,
      content: nil,
      summary: nil,
      as_cotonoma: false,
      amishi_id: amishi_id,
      posted_in_id: cotonoma_id
    )
    |> normalize_no_content()
  end

  def changeset_to_update(struct, params \\ %{}) do
    struct
    |> cast(params, [:content, :summary])
    |> validate_length(:summary, max: @summary_max_length)
    |> normalize_no_content()
    |> store_long_content()
  end

  def changeset_to_import(struct, coto_json, %Amishi{id: amishi_id}) do
    data =
      Map.merge(coto_json, %{
        "amishi_id" => amishi_id,
        "inserted_at" => unixtime_to_datetime!(coto_json["inserted_at"]),
        "updated_at" => unixtime_to_datetime!(coto_json["updated_at"])
      })

    struct
    |> cast(data, [
      :id,
      :content,
      :summary,
      :as_cotonoma,
      :posted_in_id,
      :amishi_id,
      :inserted_at,
      :updated_at
    ])
    |> validate_required([:id, :content, :amishi_id])
    |> store_long_content()
  end

  defp normalize_no_content(changeset) do
    case get_field(changeset, :content) do
      nil ->
        put_change(changeset, :content, "")

      content ->
        put_change(changeset, :content, String.trim(content))
    end
  end

  # The length of cotos.content is limited to @content_max_length
  # because it will be indexed and index row's maximum size is 8191 bytes.
  # So long content will be stored as a long_content field.
  defp store_long_content(changeset) do
    case get_field(changeset, :content) do
      nil ->
        changeset

      content ->
        if String.length(content) > @content_max_length do
          changeset
          |> put_change(:content, "")
          |> put_change(:long_content, content)
        else
          changeset
          |> put_change(:long_content, nil)
        end
    end
  end

  def get_content(%__MODULE__{content: content, long_content: long_content}) do
    long_content || content
  end

  def for_amishi(query, amishi_id) do
    from(coto in query, where: coto.amishi_id == ^amishi_id)
  end

  def in_cotonoma(query, cotonoma_id) do
    from(coto in query, where: coto.posted_in_id == ^cotonoma_id)
  end

  def peel!(%Coto{} = coto) do
    case coto.repost do
      nil -> coto
      %Ecto.Association.NotLoaded{} -> raise "coto.repost not loaded"
      repost -> repost
    end
  end
end
