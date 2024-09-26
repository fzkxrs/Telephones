require 'rake'
require 'active_record'
require_relative 'lib/modules/_utils'

namespace :db do
  desc "Migrate the database"
  task :migrate do
    ActiveRecord::Migrator.migrate('db/migrate')
  end

  desc "Seed the database"
  task :seed do
    load 'db/seeds.rb'
  end
end