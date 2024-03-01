# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative "config/application"

Rails.application.load_tasks
Rake::Task[:default].clear

# Cherry-pick of https://github.com/rails/rails/pull/39221
# No longer needed after rails upgrade
namespace :test do
  desc "Runs all tests, including system tests"
  task all: "test:prepare" do
    $: << "test"
    Rails::TestUnit::Runner.rake_run(["test/**/*_test.rb"])
  end
end

task default: Rake::Task["test:all"]
