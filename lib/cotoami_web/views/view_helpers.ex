defmodule CotoamiWeb.ViewHelpers do
  def to_unixtime(datetime) do
    if datetime, do: DateTime.to_unix(datetime, :millisecond), else: nil
  end

  def render_relation(relation, view, template) do
    case relation do
      nil -> nil
      %Ecto.Association.NotLoaded{} -> nil
      relation -> Phoenix.View.render_one(relation, view, template)
    end
  end

  def render_relations(relations, view, template) do
    case relations do
      nil -> nil
      %Ecto.Association.NotLoaded{} -> nil
      relations -> Phoenix.View.render_many(relations, view, template)
    end
  end
end
