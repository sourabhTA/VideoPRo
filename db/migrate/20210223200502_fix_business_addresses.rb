class FixBusinessAddresses < ActiveRecord::Migration[5.2]
  def up
    execute(<<~SQL)
      alter table business_addresses
        alter column user_id set not null;
      alter table business_addresses
        alter column city set not null;
      alter table business_addresses
        alter column zip set not null;
      
      create index on business_addresses (user_id);
      create index on business_addresses (zip);
      alter table business_addresses
        add foreign key (user_id) references users;
    SQL
  end

  def down
    execute(<<~SQL)
      alter table business_addresses
        drop constraint business_addresses_user_id_fkey;
      drop index business_addresses_zip_idx;
      drop index business_addresses_user_id_idx;
      alter table business_addresses
        alter column zip drop not null;
      alter table business_addresses
        alter column city drop not null;
      alter table business_addresses
        alter column user_id drop not null;
    SQL
  end
end
