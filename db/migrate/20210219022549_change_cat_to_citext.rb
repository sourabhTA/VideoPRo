class ChangeCatToCitext < ActiveRecord::Migration[5.2]
  def up
    execute(<<~SQL)
      create extension if not exists citext;
      alter table categories
        alter column name type citext;
      alter table categories
        alter column name set not null;
      create unique index on categories (name);
    SQL
  end

  def down
    execute(<<~SQL)
      drop index categories_name_idx;
      alter table categories
        alter column name drop not null;
      alter table categories
        alter column name type text;
      drop extension if exists citext;
    SQL
  end
end
