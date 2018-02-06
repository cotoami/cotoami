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
    # https://www.postgresql.org/docs/9.4/static/sql-refreshmaterializedview.html
    # "CONCURRENTLY: This option is only allowed if there is at least one UNIQUE index 
    # on the materialized view which uses only column names and includes all rows; 
    # that is, it must not index on any expressions nor include a WHERE clause."
    create unique_index(:coto_search, [:id])

    # refreshing the coto_search view
    execute(
      """
      CREATE OR REPLACE FUNCTION refresh_coto_search()
      RETURNS TRIGGER LANGUAGE plpgsql
      AS $$
      BEGIN
      REFRESH MATERIALIZED VIEW CONCURRENTLY coto_search;
      RETURN NULL;
      END $$;
      """
    )
    execute(
      """
      CREATE TRIGGER refresh_coto_search
      AFTER INSERT OR UPDATE OR DELETE OR TRUNCATE
      ON cotos
      FOR EACH STATEMENT
      EXECUTE PROCEDURE refresh_coto_search();
      """
    )
  end

  def down do
    execute("DROP INDEX IF EXISTS cotos_summary_trgm_index")
    execute("DROP INDEX IF EXISTS cotos_content_trgm_index")
    execute("DROP EXTENSION IF EXISTS pg_trgm")

    execute("DROP TRIGGER IF EXISTS refresh_coto_search ON cotos")
    execute("DROP FUNCTION IF EXISTS refresh_coto_search()")

    drop unique_index(:coto_search, [:id])
    drop index(:coto_search, [:document], using: :gist)
    execute("DROP MATERIALIZED VIEW IF EXISTS coto_search")
    execute("DROP EXTENSION IF EXISTS unaccent")
  end
end
