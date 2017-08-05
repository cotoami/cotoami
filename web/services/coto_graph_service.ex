defmodule Cotoami.CotoGraphService do
  @moduledoc """
  Provides Coto-graph related functions based on Cotoami.Neo4jService.
  """

  require Logger
  import Cotoami.Helpers
  import Ecto.Query, only: [from: 2]
  alias Phoenix.View
  alias Cotoami.{
    Repo, Coto, Amishi, Cotonoma, Neo4jService, CotoGraph, AmishiView,
    CotonomaView
  }

  @label_amishi "Amishi"
  @label_coto "Coto"
  @label_cotonoma "Cotonoma"

  @rel_type_has_a "HAS_A"

  def get_graph(%Amishi{id: amishi_id}) do
    get_graph_from_uuid(amishi_id)
  end

  def get_graph(%Cotonoma{coto: %Coto{id: cotonoma_coto_id}}) do
    get_graph_from_uuid(cotonoma_coto_id)
  end

  def get_subgraph(%Cotonoma{coto: %Coto{id: cotonoma_coto_id}}) do
    get_graph_from_uuid(cotonoma_coto_id, false)
  end

  # start with the uuid node and traverse HAS_A relationships
  # until finding the end edge or a cotonoma
  defp get_graph_from_uuid(uuid, from_root \\ true) do
    query = ~s"""
      MATCH path = ({ uuid: $uuid })-[:#{@rel_type_has_a}*0..]->
        (parent)-[has:#{@rel_type_has_a}]->(child:#{@label_coto})
      WITH size(filter(n IN tail(nodes(path)) WHERE n:#{@label_cotonoma}))
        AS subcotonomas, parent, has, child
      WHERE (child:#{@label_cotonoma} AND subcotonomas = 1) OR
        ((NOT child:#{@label_cotonoma}) AND subcotonomas = 0)
      RETURN parent, has, child
      ORDER BY has.#{Neo4jService.rel_prop_order()}
    """
    Bolt.Sips.conn
    |> Bolt.Sips.query!(query, %{uuid: uuid})
    |> Enum.reduce(%CotoGraph{}, fn(%{"parent" => parent, "has" => has, "child" => child}, graph) ->
        parent_id = parent.properties["uuid"]
        child_id = child.properties["uuid"]

        graph = %{graph | cotos: Map.put(graph.cotos, child_id, child.properties)}

        connection =
          has.properties
          |> Map.put("id", has.id)
          |> Map.put("start", parent_id)
          |> Map.put("end", child_id)

        if from_root && parent_id == uuid do
          %{graph | root_connections: [connection | graph.root_connections]}
        else
          parent_connections =
            [connection | Map.get(graph.connections, parent_id, [])]
          connections = Map.put(graph.connections, parent_id, parent_connections)
          %{graph | connections: connections}
        end
      end)
    |> (fn(graph) -> %{graph | cotos: set_relations(graph.cotos)} end).()
  end

  defp set_relations(id_to_coto_nodes) when is_map(id_to_coto_nodes) do
    amishis =
      id_to_coto_nodes
      |> Map.values()
      |> Enum.map(&(&1["amishi_id"]))
      |> to_id_model_map(Amishi, &(View.render_one &1, AmishiView, "amishi.json"))
    cotonomas =
      id_to_coto_nodes
      |> Map.values()
      |> Enum.map(&(&1["posted_in_id"]))
      |> to_id_model_map(Cotonoma, &(View.render_one &1, CotonomaView, "cotonoma.json"))
    id_to_coto_nodes
    |> Enum.map(fn({id, node}) ->
        {id,
          node
          |> Map.put("amishi", amishis[node["amishi_id"]])
          |> Map.put("posted_in", cotonomas[node["posted_in_id"]])
        }
      end)
    |> Map.new()
  end

  defp to_id_model_map(ids, queryable, to_json) do
    ids
    |> Enum.filter(&(&1))
    |> Enum.uniq()
    |> (fn(ids) -> Repo.all(from q in queryable, where: q.id in ^ids) end).()
    |> Enum.filter(&(&1))
    |> Enum.map(&({&1.id, to_json.(&1)}))
    |> Map.new()
  end

  def pin(%Coto{} = coto, %Amishi{} = amishi) do
    Bolt.Sips.conn
    |> register_amishi(amishi)
    |> register_coto(coto)
    |> Neo4jService.get_or_create_ordered_relationship!(
      amishi.id, coto.id, @rel_type_has_a, common_rel_props(amishi.id))
  end
  def pin(%Coto{} = coto, %Cotonoma{} = cotonoma, %Amishi{} = amishi) do
    Bolt.Sips.conn
    |> register_amishi(amishi)
    |> register_coto(coto)
    |> register_cotonoma(cotonoma)
    |> Neo4jService.get_or_create_ordered_relationship!(
      cotonoma.coto.id, coto.id, @rel_type_has_a, common_rel_props(amishi.id, cotonoma.id))
  end

  def unpin(%Coto{id: coto_id}, %Amishi{id: amishi_id}) do
    Bolt.Sips.conn
    |> Neo4jService.delete_relationship!(amishi_id, coto_id, @rel_type_has_a)
  end
  def unpin(%Coto{id: coto_id}, %Cotonoma{coto: %Coto{id: cotonoma_coto_id}}) do
    Bolt.Sips.conn
    |> Neo4jService.delete_relationship!(cotonoma_coto_id, coto_id, @rel_type_has_a)
  end

  def connect(%Coto{} = source, %Coto{} = target, %Amishi{id: amishi_id}) do
    do_connect(source, target, amishi_id, nil)
  end
  def connect(%Coto{} = source, %Coto{} = target, %Amishi{id: amishi_id}, %Cotonoma{id: cotonoma_id}) do
    do_connect(source, target, amishi_id, cotonoma_id)
  end
  defp do_connect(%Coto{} = source, %Coto{} = target, amishi_id, cotonoma_id) do
    rel_props = if cotonoma_id,
      do: common_rel_props(amishi_id, cotonoma_id),
      else: common_rel_props(amishi_id)
    Bolt.Sips.conn
    |> register_coto(source)
    |> register_coto(target)
    |> Neo4jService.get_or_create_ordered_relationship!(
      source.id, target.id, @rel_type_has_a, rel_props)
  end

  def disconnect(%Coto{id: source_id}, %Coto{id: target_id}, %Amishi{id: amishi_id}) do
    Bolt.Sips.conn
    |> ensure_disconnectable(source_id, target_id, amishi_id)
    |> Neo4jService.delete_relationship!(source_id, target_id, @rel_type_has_a)
  end
  def disconnect(%Coto{id: source_id}, %Coto{id: target_id}, %Amishi{id: amishi_id}, %Cotonoma{id: cotonoma_id}) do
    Bolt.Sips.conn
    |> ensure_disconnectable(source_id, target_id, amishi_id, cotonoma_id)
    |> Neo4jService.delete_relationship!(source_id, target_id, @rel_type_has_a)
  end

  defp ensure_disconnectable(conn, source_id, target_id, amishi_id, cotonoma_id \\ nil) do
    if disconnectable?(conn, source_id, target_id, amishi_id, cotonoma_id) do
      conn
    else
      raise Cotoami.Exceptions.NoPermission
    end
  end

  defp disconnectable?(conn, source_id, target_id, amishi_id, cotonoma_id) do
    case Neo4jService.get_relationship!(conn, source_id, target_id, @rel_type_has_a) do
      nil -> true
      rel ->
        case cotonoma_id do
          nil ->
            rel.properties["created_by"] == amishi_id
          cotonoma_id ->
            rel.properties["created_by"] == amishi_id or
              rel.properties["created_in"] == cotonoma_id
        end
    end
  end

  def delete_coto(coto_id) do
    Neo4jService.delete_node_with_relationships!(Bolt.Sips.conn, coto_id)
  end

  defp register_amishi(conn, %Amishi{id: amishi_id}) do
    Neo4jService.get_or_create_node!(conn, amishi_id, [@label_amishi])
    conn
  end

  defp register_coto(conn, coto) do
    labels = if coto.as_cotonoma, do: [@label_coto, @label_cotonoma], else: [@label_coto]
    props = %{
      content: coto.content,
      amishi_id: coto.amishi_id,
      cotonoma_key: (if coto.as_cotonoma, do: coto.cotonoma.key, else: nil),
      posted_in_id: coto.posted_in_id,
      inserted_at: coto.inserted_at |> DateTime.to_unix(:millisecond),
      updated_at: coto.updated_at |> DateTime.to_unix(:millisecond)
    } |> drop_nil
    Neo4jService.get_or_create_node!(conn, coto.id, labels, props)
    conn
  end

  defp register_cotonoma(conn, cotonoma) do
    labels = [@label_coto, @label_cotonoma]
    props = %{
      content: cotonoma.name,
      amishi_id: cotonoma.coto.amishi_id,
      cotonoma_key: cotonoma.key,
      posted_in_id: cotonoma.coto.posted_in_id,
      inserted_at: cotonoma.coto.inserted_at |> DateTime.to_unix(:millisecond),
      updated_at: cotonoma.updated_at |> DateTime.to_unix(:millisecond)
    } |> drop_nil
    Neo4jService.get_or_create_node!(conn, cotonoma.coto.id, labels, props)
    conn
  end

  defp common_rel_props(amishi_id) do
    %{
      created_by: amishi_id,
      created_at: System.system_time(:millisecond)
    }
  end
  defp common_rel_props(amishi_id, cotonoma_id) do
    amishi_id
    |> common_rel_props()
    |> Map.put(:created_in, cotonoma_id)
  end
end
