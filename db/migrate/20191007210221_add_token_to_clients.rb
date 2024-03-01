class AddTokenToClients < ActiveRecord::Migration[5.2]
  def change
    add_column :clients, :token, :string
    Client.all.each do |client|
      begin
        client.regenerate_token
        client.save!
      rescue => e
        puts "==========>>>>>>>>>>>>>#{e.inspect}"
      end
    end
  end
end
