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

  def get_graph(bolt_conn, %Amishi{id: amishi_id}) do
    get_graph_from_uuid(bolt_conn, amishi_id)
  end

  def get_graph(bolt_conn, %Cotonoma{coto: %Coto{id: cotonoma_coto_id}}) do
    get_graph_from_uuid(bolt_conn, cotonoma_coto_id)
  end

  def get_subgraph(bolt_conn, %Cotonoma{coto: %Coto{id: cotonoma_coto_id}}) do
    get_graph_from_uuid(bolt_conn, cotonoma_coto_id, false)
  end

  # start with the uuid node and traverse HAS_A relationships
  # until finding the end edge or a cotonoma
  defp get_graph_from_uuid(bolt_conn, uuid, from_root \\ true) do
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
    bolt_conn
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

  def pin(bolt_conn, %Coto{} = coto, %Amishi{} = amishi) do
    bolt_conn
    |> register_amishi(amishi)
    |> register_coto(coto)
    |> Neo4jService.get_or_create_ordered_relationship!(
      amishi.id, coto.id, @rel_type_has_a, common_rel_props(amishi.id))
  end
  def pin(bolt_conn, %Coto{} = coto, %Cotonoma{} = cotonoma, %Amishi{} = amishi) do
    bolt_conn
    |> register_amishi(amishi)
    |> register_coto(coto)
    |> register_cotonoma(cotonoma)
    |> Neo4jService.get_or_create_ordered_relationship!(
      cotonoma.coto.id, coto.id, @rel_type_has_a, common_rel_props(amishi.id, cotonoma.id))
  end

  def unpin(bolt_conn, %Coto{id: coto_id}, %Amishi{id: amishi_id}) do
    bolt_conn
    |> Neo4jService.delete_relationship!(amishi_id, coto_id, @rel_type_has_a)
  end
  def unpin(bolt_conn, %Coto{id: coto_id}, %Cotonoma{coto: %Coto{id: cotonoma_coto_id}}) do
    bolt_conn
    |> Neo4jService.delete_relationship!(cotonoma_coto_id, coto_id, @rel_type_has_a)
  end

  def connect(bolt_conn, %Coto{} = source, %Coto{} = target, %Amishi{} = amishi) do
    if Enum.empty? Neo4jService.get_paths!(bolt_conn, amishi.id, source.id) do
      pin(bolt_conn, source, amishi)
    end
    do_connect(bolt_conn, source, target, amishi.id, nil)
  end
  def connect(bolt_conn, %Coto{} = source, %Coto{} = target, %Amishi{} = amishi, %Cotonoma{} = cotonoma) do
    if Enum.empty? Neo4jService.get_paths!(bolt_conn, cotonoma.id, source.id) do
      pin(bolt_conn, source, cotonoma, amishi)
    end
    do_connect(bolt_conn, source, target, amishi.id, cotonoma.id)
  end
  defp do_connect(bolt_conn, %Coto{} = source, %Coto{} = target, amishi_id, cotonoma_id) do
    rel_props = if cotonoma_id,
      do: common_rel_props(amishi_id, cotonoma_id),
      else: common_rel_props(amishi_id)
    bolt_conn
    |> register_coto(source)
    |> register_coto(target)
    |> Neo4jService.get_or_create_ordered_relationship!(
      source.id, target.id, @rel_type_has_a, rel_props)
  end

  def disconnect(bolt_conn, %Coto{id: source_id}, %Coto{id: target_id}, %Amishi{id: amishi_id}) do
    bolt_conn
    |> ensure_disconnectable(source_id, target_id, amishi_id)
    |> Neo4jService.delete_relationship!(source_id, target_id, @rel_type_has_a)
  end
  def disconnect(bolt_conn, %Coto{id: source_id}, %Coto{id: target_id}, %Amishi{id: amishi_id}, %Cotonoma{id: cotonoma_id}) do
    bolt_conn
    |> ensure_disconnectable(source_id, target_id, amishi_id, cotonoma_id)
    |> Neo4jService.delete_relationship!(source_id, target_id, @rel_type_has_a)
  end

  defp ensure_disconnectable(bolt_conn, source_id, target_id, amishi_id, cotonoma_id \\ nil) do
    if disconnectable?(bolt_conn, source_id, target_id, amishi_id, cotonoma_id) do
      bolt_conn
    else
      raise Cotoami.Exceptions.NoPermission
    end
  end

  defp disconnectable?(bolt_conn, source_id, target_id, amishi_id, cotonoma_id) do
    case Neo4jService.get_relationship!(bolt_conn, source_id, target_id, @rel_type_has_a) do
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

  def delete_coto(bolt_conn, coto_id) do
    Neo4jService.delete_node_with_relationships!(bolt_conn, coto_id)
  end

  defp register_amishi(bolt_conn, %Amishi{id: amishi_id}) do
    Neo4jService.get_or_create_node!(bolt_conn, amishi_id, [@label_amishi])
    bolt_conn
  end

  defp register_coto(bolt_conn, coto) do
    labels = if coto.as_cotonoma, do: [@label_coto, @label_cotonoma], else: [@label_coto]
    props = %{
      content: coto.content,
      amishi_id: coto.amishi_id,
      cotonoma_key: (if coto.as_cotonoma, do: coto.cotonoma.key, else: nil),
      posted_in_id: coto.posted_in_id,
      inserted_at: coto.inserted_at |> DateTime.to_unix(:millisecond),
      updated_at: coto.updated_at |> DateTime.to_unix(:millisecond)
    } |> drop_nil
    Neo4jService.get_or_create_node!(bolt_conn, coto.id, labels, props)
    bolt_conn
  end

  defp register_cotonoma(bolt_conn, cotonoma) do
    labels = [@label_coto, @label_cotonoma]
    props = %{
      content: cotonoma.name,
      amishi_id: cotonoma.coto.amishi_id,
      cotonoma_key: cotonoma.key,
      posted_in_id: cotonoma.coto.posted_in_id,
      inserted_at: cotonoma.coto.inserted_at |> DateTime.to_unix(:millisecond),
      updated_at: cotonoma.updated_at |> DateTime.to_unix(:millisecond)
    } |> drop_nil
    Neo4jService.get_or_create_node!(bolt_conn, cotonoma.coto.id, labels, props)
    bolt_conn
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
