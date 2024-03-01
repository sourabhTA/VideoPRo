require "mina/bundler"
require "mina/rails"
require "mina/git"
require "mina/rvm"

environment = ENV.fetch("to", "staging")

set :domain, "142.93.83.197"

if environment == "production"
  set :domain, "138.68.253.118"
  set :rails_env, "production"
  # set :domain, "videochatapro.com"
else
  set :rails_env, "staging"
end

set :repository, "https://robertflan:K7dgQpCchPLfnzd6LcwB@bitbucket.org/videochatapro/video-chat-a-pro.git"
set :deploy_to, "/home/videochatapro/videochatapro"
# set :branch, "fix/header-seo-prod"
# set :branch, "feat/purge-css-for-performance"
set :branch, "fix-cms-1"
# set :branch, "master"
set :forward_agent, true
set :user, "videochatapro"
set :keep_releases, 4

set :shared_dirs, fetch(:shared_dirs, []).concat(%w[
    log
    tmp/pids
    tmp/cache
    public/assets
    public/uploads
    db/backups
  ])

set :shared_files, fetch(:shared_files, []).concat(%w[
    config/application.yml
    public/sitemap.xml.gz
    public/ads.txt
  ])

task :remote_environment do
  invoke :'rvm:use', "ruby-2.7.2"
end

desc "Make sure local git is in sync with remote."
task :check_revision do
  unless `git rev-parse HEAD` == `git rev-parse origin/#{fetch :branch}`
    puts "WARNING: HEAD is not the same as origin/#{fetch :branch}"
    puts "Run `git push` to sync changes."
    exit
  end
end

desc "Deploys the App."
task deploy: :remote_environment do
  deploy do
    invoke :check_revision
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    command 'yarn install'
    invoke :'bundle:install'
    invoke :'rails:db_migrate'
    invoke :'rails:assets_precompile'
    command 'bundle exec rake purge_css:clear'
    # command 'bundle exec rake purge_css:run'
    invoke :'deploy:cleanup'

    on :launch do
      invoke :'puma:restart'

      in_path(fetch(:current_path)) do
        invoke :'delayed_job:restart'
        invoke :'maintenance:off'
      end
    end
  end
end

namespace :logs do
  desc "Follows the log file."
  task :rails do
    comment 'echo "Contents of the log file are as follows:"'
    command "tail -f #{fetch :deploy_to}/current/log/production.log"
  end
end

namespace :puma do
  task :restart do
    comment "Restarting puma"
    command "sudo /usr/bin/systemctl restart puma.service"
  end
end

namespace :delayed_job do
  task :restart do
    comment "Restarting delayed_job worker"
    command "sudo /usr/bin/systemctl stop delayed_job.service"
    command "sudo /usr/bin/systemctl start delayed_job.service"
  end
end

namespace :maintenance do
  task :on do
    comment "Enabling maintenance mode"
    command "if [ -d \"#{fetch :deploy_to}/current\" ]; then touch #{fetch :deploy_to}/current/public/maintenance; fi"
  end

  task :off do
    comment "Disabling maintenance mode"
    command "rm -f #{fetch :deploy_to}/current/public/maintenance"
  end
end

namespace :pg do
  desc "Creates a postgres backup."
  task backup: :remote_environment do
    comment "Dumping database"

    in_path(fetch(:current_path)) do
      command "RAILS_ENV=production bundle exec rake db_dump:take"
      command "ls -1 #{fetch :deploy_to}/shared/db/backups"
    end
  end
end

desc "List deployed git sha"
task current_version: :remote_environment do
  in_path(fetch(:current_path)) do
    command "echo -en \"\033[32m\""
    command "cat #{fetch :deploy_to}/scm/FETCH_HEAD"
    command "echo -en \"\033[0m\""
  end
end

desc "Manually refresh the sitemap (this happens automatically at 5am)"
task refresh_sitemap: :remote_environment do
  comment "Manually refreshing sitemap"

  in_path(fetch(:current_path)) do
    command "RAILS_ENV=production bundle exec rake sitemap:refresh"
  end
end
