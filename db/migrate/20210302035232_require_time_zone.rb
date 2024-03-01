class RequireTimeZone < ActiveRecord::Migration[5.2]
  def up
    tz = "Eastern Time (US & Canada)"

    execute(<<~SQL)
      update users
        set time_zone = '#{tz}'
      where time_zone is null;

      alter table users
        alter column time_zone set default '#{tz}';

      alter table users
        alter column time_zone set not null;
    SQL
  end

  def down
    execute(<<~SQL)
      alter table users
        alter column time_zone drop not null;

      alter table users
        alter column time_zone drop default;
    SQL
  end
end
