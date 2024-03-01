class AddTzToTimings < ActiveRecord::Migration[5.2]
  def up
    execute(<<~SQL)
      alter table video_chats
        alter column timings type timestamptz;
    SQL
  end

  def down
    execute(<<~SQL)
      alter table video_chats
        alter column timings type timestamp;
    SQL
  end
end
