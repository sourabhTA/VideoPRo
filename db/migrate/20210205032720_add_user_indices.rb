class AddUserIndices < ActiveRecord::Migration[5.2]
  def up
    execute(<<~SQL)
      create index on users (is_hidden);
      create index on users (slug);
      create index on users (scrapped_link);
      create index on users (role);
    SQL
  end

  def down
    execute(<<~SQL)
      drop index users_role_idx;
      drop index users_scrapped_link_idx;
      drop index users_slug_idx;
      drop index users_is_hidden_idx;
    SQL
  end
end
