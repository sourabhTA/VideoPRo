class AddBookingsTokens < ActiveRecord::Migration[5.2]
  def up
    execute(<<~SQL)
      create extension if not exists "uuid-ossp";

      alter table bookings
        add column client_token uuid not null unique default uuid_generate_v4();
      alter table bookings
        add column professional_token uuid not null unique default uuid_generate_v4();
    SQL
  end

  def down
    execute(<<~SQL)
      alter table bookings
        drop column client_token;
      alter table bookings
        drop column professional_token;

      drop extension if exists "uuid-ossp";
    SQL
  end
end
