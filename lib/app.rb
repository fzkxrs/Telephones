require 'yaml'
require_relative 'gui'
require_relative 'database'
require_relative 'test_database'

db_config = YAML.load_file('config/database.yml')['development']
db = Database.new(db_config)
test_db = TestDatabase.new(db_config)
test_db.setup_test_data
app = GUI.new(db)
app.run

#after all
# test_db.clear_test_data