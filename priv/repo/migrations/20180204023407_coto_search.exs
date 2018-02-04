defmodule Cotoami.Repo.Migrations.CotoSearch do
  use Ecto.Migration

  def up do
    # to support substring summary/content matches with ILIKE
    # https://www.postgresql.org/docs/9.1/static/pgtrgm.html
    # https://www.postgresql.org/docs/9.1/static/textsearch-indexes.html
    execute("CREATE EXTENSION IF NOT EXISTS pg_trgm")
    execute(
      """
      CREATE INDEX cotos_summary_trgm_index ON cotos 
      USING gist (summary gist_trgm_ops)
      """
    )
    execute(
      """
      CREATE INDEX cotos_content_trgm_index ON cotos 
      USING gist (content gist_trgm_ops)
      """
    )

    execute("CREATE EXTENSION IF NOT EXISTS unaccent")

    execute(
      """
      CREATE MATERIALIZED VIEW coto_search AS
      SELECT
        cotos.id AS id,
        (
          setweight(to_tsvector(unaccent(coalesce(cotonomas.name, ' '))), 'A') ||
          setweight(to_tsvector(unaccent(coalesce(cotos.summary, ' '))), 'B') ||
          setweight(to_tsvector(unaccent(cotos.content)), 'C')
        ) AS document
      FROM cotos
      LEFT JOIN cotonomas ON cotonomas.coto_id = cotos.id
      """
    )

    # to support full-text searches
    create index(:coto_search, [:document], using: :gist)

    # to support updating CONCURRENTLY
    create unique_index(:coto_search, [:id])
  end

  def down do
    execute("DROP EXTENSION pg_trgm")
    execute("DROP INDEX cotos_summary_trgm_index")
    execute("DROP INDEX cotos_content_trgm_index")

    execute("DROP EXTENSION unaccent")

    execute("DROP MATERIALIZED VIEW coto_search")

    drop index(:coto_search, [:document], using: :gist)

    drop unique_index(:coto_search, [:id])
  end
end
