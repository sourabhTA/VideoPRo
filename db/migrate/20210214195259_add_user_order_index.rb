class AddUserOrderIndex < ActiveRecord::Migration[5.2]
  def up
    execute(<<~SQL)
      create index role_visible_sort_idx on users (role) where (name is not null and not is_hidden and slug is not null and scrapped_link is null);
    SQL
  end

  def down
    execute(<<~SQL)
      drop index role_visible_sort_idx;
    SQL
  end
end
