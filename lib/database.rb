require 'pg'
require 'active_record'
require 'yaml'

db_config = YAML.load_file('config/database.yml')['development']
ActiveRecord::Base.establish_connection(db_config)

class Employee < ActiveRecord::Base
end