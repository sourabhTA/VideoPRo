class AddVideosToVideo < ActiveRecord::Migration[5.2]
  def up
    execute(<<~SQL)
      create table videos (
        id uuid primary key default uuid_generate_v4(),
        name text unique,
        video jsonb,
        created_at timestamptz not null default now(),
        updated_at timestamptz not null default now()
      )
    SQL
  end

  def down
    execute(<<~SQL)
      drop table videos;
    SQL
  end
end
