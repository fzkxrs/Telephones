require 'yaml'
require_relative './gui'
require_relative './database'

db_config = YAML.load_file('config/database.yml')['development']
db = Database.new(db_config)
db.setup_test_data
app = GUI.new(db)
app.run

#after all
db.clear_test_data