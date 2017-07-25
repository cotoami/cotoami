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
  when is_binary(uuid) and is_list(labels) and is_map(props) do
    query = ~s"""
      MERGE (node#{labels_in_query(labels)} { uuid: $uuid })
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

  def create_relationship(from_uuid, to_uuid, labels \\ [])
  when is_binary(from_uuid) and is_binary(to_uuid) and is_list(labels) do
    query = ~s"""
      MATCH (from { uuid: $from_uuid }),(to { uuid: $to_uuid })
      MERGE (from)-[r#{labels_in_query(labels)}]->(to)
      RETURN r
    """

  end

  defp labels_in_query(labels) do
    if length(labels) > 0, do: ":" <> Enum.join(labels, ":"), else: ""
  end
end
