defmodule Myhp.Repo.Migrations.AddCascadeDeleteToComments do
  use Ecto.Migration

  # SQLite doesn't support ALTER CONSTRAINT, so we need to recreate the table
  def up do
    # Create new table with cascade delete
    execute """
    CREATE TABLE comments_new (
      id INTEGER PRIMARY KEY,
      content TEXT,
      user_id INTEGER REFERENCES users(id),
      post_id INTEGER REFERENCES posts(id) ON DELETE CASCADE,
      inserted_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    )
    """

    # Copy data
    execute "INSERT INTO comments_new SELECT * FROM comments"

    # Drop old table and rename new one
    execute "DROP TABLE comments"
    execute "ALTER TABLE comments_new RENAME TO comments"

    # Recreate indexes
    execute "CREATE INDEX comments_user_id_index ON comments(user_id)"
    execute "CREATE INDEX comments_post_id_index ON comments(post_id)"
  end

  def down do
    # Recreate original table without cascade delete
    execute """
    CREATE TABLE comments_new (
      id INTEGER PRIMARY KEY,
      content TEXT,
      user_id INTEGER REFERENCES users(id),
      post_id INTEGER REFERENCES posts(id),
      inserted_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    )
    """

    execute "INSERT INTO comments_new SELECT * FROM comments"
    execute "DROP TABLE comments"
    execute "ALTER TABLE comments_new RENAME TO comments"
    execute "CREATE INDEX comments_user_id_index ON comments(user_id)"
    execute "CREATE INDEX comments_post_id_index ON comments(post_id)"
  end
end
