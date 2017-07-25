defmodule Cotoami.GraphService do
  require Logger
  alias Cotoami.Coto
  alias Cotoami.Amishi
  alias Cotoami.Cotonoma

  def pin(
    %Coto{} = coto,
    %Amishi{id: amishi_id},
    %Cotonoma{id: cotonoma_id, coto: %Coto{id: cotonoma_coto_id}} \\ nil
  ) do

  end

  def get_or_create_node(uuid, labels \\ [], props \\ %{})
  when is_list(labels) and is_binary(uuid) and is_map(props) do
    labelsString =
      if length(labels) > 0,
        do: ":" <> Enum.join(labels, ":"),
        else: ""
    query = ~s"""
      MERGE (node#{labelsString} { uuid: $uuid })
      ON CREATE SET node=$props
      RETURN node
    """
    [%{"node" => node}] =
      Bolt.Sips.conn
      |> Bolt.Sips.query!(query, %{
        uuid: uuid,
        props: Map.put(props, :uuid, uuid)
      })
    node
  end
end
