require_relative './test_database'
require 'yaml'

db_config_path = File.expand_path('../config/database.yml', __dir__)
db_config = YAML.load_file(db_config_path)['test']
db = TestDatabase.new(db_config)

# Setup test data
db.setup_test_data
puts "Test data loaded successfully!"

# Ensure the connection is correct before running any query
db = TestDatabase.new(db_config)
db.test_connection

# Test search
res = db.search_employee( 'Some Enterprise', 'IT', 'Software', 'Lab A', 'John Doe', '1001',)
if res
  res.each do |row|
    puts "Found: #{row['enterprise']}, #{row['department']}"
  end
else
  puts "No results found."
end
db.open_connection
db.clear_test_data
