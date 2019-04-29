defmodule Cotoami.CotoGraphService do
  @moduledoc """
  Provides Coto-graph related functions based on Cotoami.Neo4jService.
  """

  require Logger
  import Cotoami.Helpers
  import Ecto.Query, only: [from: 2]
  alias Phoenix.View
  alias Bolt.Sips.Types.Node
  alias Bolt.Sips.Types.Relationship
  alias Cotoami.{Repo, Coto, Amishi, Cotonoma, CotoGraph, Neo4jService}
  alias CotoamiWeb.{AmishiView, CotonomaView}

  @label_amishi "Amishi"
  @label_coto "Coto"
  @label_cotonoma "Cotonoma"

  @type_connection "HAS_A"

  def get_graph_in_amishi(bolt_conn, %Amishi{id: amishi_id}) do
    query =
      query_graph_from_uuid() <>
        ~s"""
          UNION

          MATCH (parent:#{@label_coto})-[has:#{@type_connection}
            { created_by: $created_by }]->(child:#{@label_coto})
          WHERE NOT exists(has.created_in)
          WITH DISTINCT parent, has, child
          ORDER BY has.created_at DESC
          LIMIT 100

          RETURN parent, has, child
          ORDER BY has.#{Neo4jService.rel_prop_order()}
        """

    bolt_conn
    |> Bolt.Sips.query!(query, %{uuid: amishi_id, created_by: amishi_id})
    |> build_graph_from_query_result(amishi_id, true)
  end

  def get_graph_in_cotonoma(
        bolt_conn,
        %Cotonoma{id: cotonoma_id, coto: %Coto{id: cotonoma_coto_id}} = cotonoma,
        %Amishi{} = amishi
      ) do
    Cotonoma.ensure_accessible_by(cotonoma, amishi)

    query =
      query_graph_from_uuid() <>
        ~s"""
          UNION

          MATCH (parent:#{@label_coto})-[has:#{@type_connection}
            { created_in: $created_in }]->(child:#{@label_coto})
          WITH DISTINCT parent, has, child
          ORDER BY has.created_at DESC
          LIMIT 100

          RETURN parent, has, child
          ORDER BY has.#{Neo4jService.rel_prop_order()}
        """

    bolt_conn
    |> Bolt.Sips.query!(query, %{uuid: cotonoma_coto_id, created_in: cotonoma_id})
    |> build_graph_from_query_result(cotonoma_coto_id, true)
  end

  def get_graph_from_uuid(bolt_conn, uuid) do
    bolt_conn
    |> Bolt.Sips.query!(query_graph_from_uuid(), %{uuid: uuid})
    |> build_graph_from_query_result(uuid, false)
  end

  def get_graph_from_cotonoma(
        bolt_conn,
        %Cotonoma{coto: %Coto{id: cotonoma_coto_id}} = cotonoma,
        %Amishi{} = amishi
      ) do
    Cotonoma.ensure_accessible_by(cotonoma, amishi)
    get_graph_from_uuid(bolt_conn, cotonoma_coto_id)
  end

  # start with the uuid node and traverse HAS_A relationships
  # until finding an end edge or a cotonoma
  defp query_graph_from_uuid do
    ~s"""
      MATCH path = ({ uuid: $uuid })-[:#{@type_connection}*0..]->
        (parent)-[has:#{@type_connection}]->(child:#{@label_coto})
      WITH size(filter(n IN tail(nodes(path)) WHERE n:#{@label_cotonoma}))
        AS subcotonomas, parent, has, child
      WHERE (child:#{@label_cotonoma} AND subcotonomas = 1) OR
        ((NOT child:#{@label_cotonoma}) AND subcotonomas = 0)
      RETURN DISTINCT parent, has, child
      ORDER BY has.#{Neo4jService.rel_prop_order()}
    """
  end

  defp build_graph_from_query_result(query_result, start_uuid, from_root) do
    query_result
    |> Enum.reduce(%CotoGraph{}, fn %{"parent" => parent, "has" => has, "child" => child}, graph ->
      graph = %{
        graph
        | cotos:
            graph.cotos
            |> add_coto(parent)
            |> add_coto(child)
      }

      parent_id = parent.properties["uuid"]
      child_id = child.properties["uuid"]

      connection = make_connection_json(has, parent_id, child_id)

      if from_root && parent_id == start_uuid do
        %{graph | root_connections: [connection | graph.root_connections]}
      else
        parent_connections = [connection | Map.get(graph.connections, parent_id, [])]
        connections = Map.put(graph.connections, parent_id, parent_connections)
        %{graph | connections: connections}
      end
    end)
    |> convert_coto_nodes_into_coto_jsons()
  end

  defp make_connection_json(%Relationship{id: id, properties: properties}, start_uuid, end_uuid) do
    properties
    |> Map.put("id", id)
    |> Map.put("start", start_uuid)
    |> Map.put("end", end_uuid)
  end

  defp add_coto(%{} = cotos, %Node{labels: labels, properties: properties}) do
    if @label_coto in labels do
      coto_id = properties["uuid"]
      Map.put(cotos, coto_id, properties)
    else
      cotos
    end
  end

  defp convert_coto_nodes_into_coto_jsons(
         %CotoGraph{
           cotos: id_to_coto_nodes,
           root_connections: root_connections,
           connections: id_to_connections
         } = graph
       ) do
    coto_nodes = Map.values(id_to_coto_nodes)
    amishi_jsons = get_amishi_jsons_in_coto_nodes(coto_nodes)
    posted_in_jsons = get_posted_in_jsons_in_coto_nodes(coto_nodes)
    cotonoma_jsons = get_cotonoma_jsons_in_coto_nodes(coto_nodes)
    connections = Map.values(id_to_connections) |> List.flatten()

    id_to_coto =
      id_to_coto_nodes
      |> Enum.map(fn {coto_id, node} ->
        incoming =
          Enum.count(root_connections, &(&1["end"] == coto_id)) +
            Enum.count(connections, &(&1["end"] == coto_id))

        outgoing = Enum.count(connections, &(&1["start"] == coto_id))

        {coto_id,
         node
         |> Map.put("id", coto_id)
         |> Map.put("amishi", amishi_jsons[node["amishi_id"]])
         |> Map.put("posted_in", posted_in_jsons[node["posted_in_id"]])
         |> Map.put("as_cotonoma", node["cotonoma_key"] != nil)
         |> Map.put("cotonoma", cotonoma_jsons[node["cotonoma_key"]])
         |> Map.put("incoming", incoming)
         |> Map.put("outgoing", outgoing)}
      end)
      |> Map.new()

    %{graph | cotos: id_to_coto}
  end

  defp get_amishi_jsons_in_coto_nodes(coto_nodes) do
    coto_nodes
    |> Enum.map(& &1["amishi_id"])
    |> Enum.filter(& &1)
    |> Enum.uniq()
    |> (fn ids -> Repo.all(from(a in Amishi, where: a.id in ^ids)) end).()
    |> Enum.map(&{&1.id, View.render_one(&1, AmishiView, "amishi.json")})
    |> Map.new()
  end

  defp get_posted_in_jsons_in_coto_nodes(coto_nodes) do
    coto_nodes
    |> Enum.map(& &1["posted_in_id"])
    |> Enum.filter(& &1)
    |> Enum.uniq()
    |> (fn ids -> Repo.all(from(c in Cotonoma, where: c.id in ^ids)) end).()
    |> Enum.map(&{&1.id, View.render_one(&1, CotonomaView, "cotonoma.json")})
    |> Map.new()
  end

  defp get_cotonoma_jsons_in_coto_nodes(coto_nodes) do
    coto_nodes
    |> Enum.map(& &1["cotonoma_key"])
    |> Enum.filter(& &1)
    |> Enum.uniq()
    |> (fn keys -> Repo.all(from(c in Cotonoma, where: c.key in ^keys)) end).()
    |> Enum.map(&{&1.key, View.render_one(&1, CotonomaView, "cotonoma.json")})
    |> Map.new()
  end

  def export_connections_by_amishi(bolt_conn, %Amishi{id: amishi_id}) do
    query = ~s"""
      MATCH (parent)-[has:#{@type_connection} { created_by: $amishi_id }]->(child)
      RETURN DISTINCT parent, has, child
      ORDER BY has.created_at
    """

    bolt_conn
    |> Bolt.Sips.query!(query, %{amishi_id: amishi_id})
    |> Enum.map(fn %{"parent" => parent, "has" => has, "child" => child} ->
      has.properties
      |> Map.put("start", parent.properties["uuid"])
      |> Map.put("end", child.properties["uuid"])
    end)
  end

  def count_connections_in_cotonoma(bolt_conn, %Cotonoma{id: cotonoma_id}) do
    query = ~s"""
      MATCH (parent)-[has:#{@type_connection} { created_in: $created_in }]->(child)
      RETURN count(DISTINCT has) AS connections
    """

    case Bolt.Sips.query!(bolt_conn, query, %{created_in: cotonoma_id}) do
      [%{"connections" => connections}] -> connections
      _ -> 0
    end
  end

  def pin(bolt_conn, %Coto{} = coto, linking_phrase, %Amishi{} = amishi) do
    bolt_conn
    |> register(amishi)
    |> register(coto)
    |> Neo4jService.get_or_create_ordered_relationship(
      amishi.id,
      coto.id,
      @type_connection,
      connection_props(amishi, linking_phrase)
    )
  end

  def pin(bolt_conn, %Coto{} = coto, %Cotonoma{} = cotonoma, linking_phrase, %Amishi{} = amishi) do
    bolt_conn
    |> register(cotonoma)
    |> register(coto)
    |> Neo4jService.get_or_create_ordered_relationship(
      cotonoma.coto.id,
      coto.id,
      @type_connection,
      connection_props(amishi, linking_phrase, cotonoma)
    )
  end

  def pinned_cotonoma_keys(bolt_conn, %Amishi{id: amishi_id}) do
    query = ~s"""
      MATCH ({ uuid: $uuid })-[has:#{@type_connection}]->(cotonoma:#{@label_cotonoma})
      RETURN cotonoma.cotonoma_key AS key
      ORDER BY has.#{Neo4jService.rel_prop_order()}
    """

    bolt_conn
    |> Bolt.Sips.query!(query, %{uuid: amishi_id})
    |> Enum.map(& &1["key"])
  end

  def unpin(bolt_conn, %Coto{id: coto_id}, %Amishi{id: amishi_id}) do
    bolt_conn
    |> Neo4jService.delete_relationship(amishi_id, coto_id, @type_connection)
  end

  def unpin(
        bolt_conn,
        %Coto{} = coto,
        %Cotonoma{coto: %Coto{} = cotonoma_coto, owner: cotonoma_owner},
        %Amishi{} = amishi
      ) do
    # expect the associations of cotonoma.coto to be missing
    cotonoma_coto = %{cotonoma_coto | amishi: cotonoma_owner}

    bolt_conn
    |> ensure_amishi_has_permission_to_update_connection(amishi, cotonoma_coto, coto)
    |> Neo4jService.delete_relationship(cotonoma_coto.id, coto.id, @type_connection)
  end

  def connect(bolt_conn, %Coto{} = source, %Coto{} = target, linking_phrase, %Amishi{} = amishi) do
    do_connect(bolt_conn, source, target, linking_phrase, amishi, nil)
  end

  def connect(
        bolt_conn,
        %Coto{} = source,
        %Coto{} = target,
        linking_phrase,
        %Amishi{} = amishi,
        %Cotonoma{} = cotonoma
      ) do
    do_connect(bolt_conn, source, target, linking_phrase, amishi, cotonoma)
  end

  defp do_connect(
         bolt_conn,
         %Coto{} = source,
         %Coto{} = target,
         linking_phrase,
         %Amishi{} = amishi,
         cotonoma
       ) do
    rel_props =
      case cotonoma do
        nil -> connection_props(amishi, linking_phrase)
        cotonoma -> connection_props(amishi, linking_phrase, cotonoma)
      end

    bolt_conn
    |> register(source)
    |> register(target)
    |> Neo4jService.get_or_create_ordered_relationship(
      source.id,
      target.id,
      @type_connection,
      rel_props
    )
  end

  def import_connection(
        bolt_conn,
        %Coto{id: _} = target,
        connection_json,
        %Amishi{id: _} = amishi
      ) do
    connection_props = connection_props_from_json(connection_json, amishi)

    bolt_conn
    |> register(amishi)
    |> register(target)
    |> Neo4jService.get_or_create_relationship(
      amishi.id,
      target.id,
      @type_connection,
      connection_props
    )
  end

  def import_connection(
        bolt_conn,
        %Coto{id: _} = source,
        %Coto{id: _} = target,
        connection_json,
        %Amishi{id: _} = amishi
      ) do
    connection_props = connection_props_from_json(connection_json, amishi)

    bolt_conn
    |> register(source)
    |> register(target)
    |> Neo4jService.get_or_create_relationship(
      source.id,
      target.id,
      @type_connection,
      connection_props
    )
  end

  defp connection_props_from_json(connection_json, %Amishi{id: amishi_id}) do
    %{
      created_by: amishi_id,
      created_at: connection_json["created_at"],
      created_in: connection_json["created_in"],
      linking_phrase: connection_json["linking_phrase"],
      order: connection_json["order"]
    }
    |> drop_nil
  end

  def disconnect(bolt_conn, %Coto{} = source, %Coto{} = target, %Amishi{} = amishi) do
    bolt_conn
    |> ensure_amishi_has_permission_to_update_connection(amishi, source, target)
    |> Neo4jService.delete_relationship(source.id, target.id, @type_connection)
  end

  def update_connection(
        bolt_conn,
        %Coto{id: source_id} = source,
        %Coto{id: target_id} = target,
        linking_phrase,
        reverse,
        %Amishi{} = amishi
      ) do
    ensure_amishi_has_permission_to_update_connection(bolt_conn, amishi, source, target)

    rel =
      Neo4jService.set_relationship_properties(
        bolt_conn,
        source_id,
        target_id,
        @type_connection,
        %{
          linking_phrase: linking_phrase
        }
      )

    case rel do
      nil ->
        nil

      rel ->
        if reverse do
          reversed_rel =
            Neo4jService.reverse_relationship(bolt_conn, source_id, target_id, @type_connection)

          make_connection_json(reversed_rel, target_id, source_id)
        else
          make_connection_json(rel, source_id, target_id)
        end
    end
  end

  defp ensure_amishi_has_permission_to_update_connection(
         bolt_conn,
         %Amishi{} = amishi,
         %Coto{} = source,
         %Coto{} = target
       ) do
    if has_permission_to_update_connection?(bolt_conn, amishi, source, target) do
      bolt_conn
    else
      raise Cotoami.Exceptions.NoPermission
    end
  end

  def has_permission_to_update_connection?(
        bolt_conn,
        %Amishi{id: amishi_id} = amishi,
        %Coto{id: source_id, amishi: %Amishi{id: source_amishi_id}},
        %Coto{id: target_id}
      ) do
    if Map.get(amishi, :owner) || source_amishi_id == amishi_id do
      true
    else
      case Neo4jService.get_relationship(bolt_conn, source_id, target_id, @type_connection) do
        nil -> true
        rel -> rel.properties["created_by"] == amishi_id
      end
    end
  end

  def delete_coto(bolt_conn, coto_id) do
    Neo4jService.delete_node_with_relationships(bolt_conn, coto_id)
  end

  def sync(bolt_conn, %Coto{id: uuid} = coto) do
    case Neo4jService.replace_node_properties(bolt_conn, uuid, node_props(coto)) do
      {:ok, node} ->
        cond do
          coto.as_cotonoma and not Enum.member?(node.labels, @label_cotonoma) ->
            Neo4jService.set_labels!(bolt_conn, uuid, [@label_cotonoma])

          true ->
            node
        end

      _ ->
        nil
    end
  end

  defp node_labels(%Coto{} = coto) do
    if coto.as_cotonoma,
      do: [@label_coto, @label_cotonoma],
      else: [@label_coto]
  end

  defp node_props(%Coto{} = coto) do
    %{
      content: coto.content,
      summary: coto.summary,
      amishi_id: coto.amishi_id,
      cotonoma_key: if(coto.as_cotonoma, do: coto.cotonoma.key, else: nil),
      posted_in_id: coto.posted_in_id,
      inserted_at: coto.inserted_at |> DateTime.to_unix(:millisecond),
      updated_at: coto.updated_at |> DateTime.to_unix(:millisecond)
    }
    |> drop_nil
  end

  defp node_props(%Cotonoma{} = cotonoma) do
    %{
      content: cotonoma.name,
      amishi_id: cotonoma.coto.amishi_id,
      cotonoma_key: cotonoma.key,
      posted_in_id: cotonoma.coto.posted_in_id,
      inserted_at: cotonoma.coto.inserted_at |> DateTime.to_unix(:millisecond),
      updated_at: cotonoma.updated_at |> DateTime.to_unix(:millisecond)
    }
    |> drop_nil
  end

  defp register(bolt_conn, %Amishi{id: amishi_id}) do
    Neo4jService.get_or_create_node(bolt_conn, amishi_id, [@label_amishi])
    bolt_conn
  end

  defp register(bolt_conn, %Coto{} = coto) do
    Neo4jService.get_or_create_node(bolt_conn, coto.id, node_labels(coto), node_props(coto))
    bolt_conn
  end

  defp register(bolt_conn, %Cotonoma{} = cotonoma) do
    labels = [@label_coto, @label_cotonoma]

    Neo4jService.get_or_create_node(
      bolt_conn,
      cotonoma.coto.id,
      labels,
      node_props(cotonoma)
    )

    bolt_conn
  end

  defp connection_props(%Amishi{id: amishi_id}, linking_phrase) do
    %{
      created_by: amishi_id,
      created_at: System.system_time(:millisecond),
      linking_phrase: linking_phrase
    }
    |> drop_nil
  end

  defp connection_props(%Amishi{} = amishi, linking_phrase, %Cotonoma{id: cotonoma_id}) do
    connection_props(amishi, linking_phrase)
    |> Map.put(:created_in, cotonoma_id)
  end

  def reorder_connections(
        bolt_conn,
        %Amishi{id: amishi_id},
        target_uuids
      )
      when is_list(target_uuids) do
    bolt_conn
    |> Neo4jService.update_relationships_order(amishi_id, target_uuids, @type_connection)
  end

  def reorder_connections(
        bolt_conn,
        %Coto{id: source_uuid} = source,
        target_uuids,
        %Amishi{} = amishi
      )
      when is_list(target_uuids) do
    bolt_conn
    |> ensure_reorderable(source, amishi)
    |> Neo4jService.update_relationships_order(source_uuid, target_uuids, @type_connection)
  end

  defp ensure_reorderable(
         bolt_conn,
         %Coto{} = source,
         %Amishi{} = amishi
       ) do
    if reorderable?(source, amishi) do
      bolt_conn
    else
      raise Cotoami.Exceptions.NoPermission
    end
  end

  def reorderable?(
        %Coto{amishi: %Amishi{id: source_amishi_id}},
        %Amishi{id: amishi_id} = amishi
      ) do
    Map.get(amishi, :owner) || source_amishi_id == amishi_id
  end
end
