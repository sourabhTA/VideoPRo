class ChangePageToLink < ActiveRecord::Migration[5.2]
  def up
    execute(<<~SQL)
      alter table home_page_trades
        add column link text;

      update home_page_trades
        set link = '/diy';

      alter table home_page_trades
        alter column link set not null;

      alter table home_page_trades
        drop column page_id;
    SQL
  end

  def down
    execute(<<~SQL)
      alter table home_page_trades
        add column page_id int references pages;

      update home_page_trades
        set page_id = 1;

      alter table home_page_trades
        alter column page_id set not null;

      alter table home_page_trades
        drop column link;
    SQL
  end
end
