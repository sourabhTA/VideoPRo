class FixAdminVideoChats < ActiveRecord::Migration[5.2]
  def up
    execute(<<~SQL)
      alter table admin_video_chats
        add column client_token uuid not null unique default uuid_generate_v4();
      alter table admin_video_chats
        add column professional_token uuid not null unique default uuid_generate_v4();
    SQL
  end

  def down
    execute(<<~SQL)
      alter table admin_video_chats
        drop column client_token;
      alter table admin_video_chats
        drop column professional_token;
    SQL
  end
end
