namespace :db_dump do
  desc "Backup database"
  task take: :environment do
    db = ActiveRecord::Base.connection_config[:database]
    file = Time.current.strftime("%Y%m%d%H%M%S") + ".dump"
    root_path = Rails.root.join("db/backups")
    mkdir_cmd = "mkdir -p #{root_path}"
    puts mkdir_cmd
    `#{mkdir_cmd}`

    output_path = "#{root_path}/#{file}"
    cmd = "pg_dump -Fc #{db} > #{output_path}"
    puts cmd
    `#{cmd}`

    n = 10
    puts "Keeping last #{n} backups"
    cmd = "cd #{root_path} && ls -1t | tail -n +#{n + 1} | xargs rm -f"
    puts cmd
    exec cmd
  end
end
