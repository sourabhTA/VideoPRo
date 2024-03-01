class HomePageTrades < ActiveRecord::Migration[5.2]
  def up
    execute(<<~SQL)
      create table home_page_trades (
        id bigint generated by default as identity primary key,
        title text not null,
        video jsonb not null,
        poster jsonb not null,
        page_id int not null references pages,
        body text not null,
        created_at timestamptz not null default now(),
        updated_at timestamptz not null default now()
      );
    SQL
  end

  def down
    execute(<<~SQL)
      drop table home_page_trades;
    SQL
  end
end
