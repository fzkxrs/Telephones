require 'logger'
require 'yaml'
require_relative 'gui'
require_relative 'database'
require_relative 'test_database'

require 'logger'

# Initialize the logger
log_file = 'application.log'
@logger = Logger.new(log_file)

# Set logger level
@logger.level = Logger::DEBUG

# Log an example message
@logger.info("Program started")

# Function to clear the log file if the program closes as expected
at_exit do
  @logger.info("Program exited as expected")

  # Close the logger before attempting to truncate the log file
  @logger.close

  # Check if the program exited normally (no unhandled exceptions)
  if $!.nil?
    begin
      # Clear the log file on a successful exit
      File.truncate(log_file, 0)
    rescue Errno::EACCES => e
      @logger.error( "Error truncating log file: #{e.message}")
    end
  else
    @logger.error("Program exited with an error: #{$!.message}")
  end
end

# Your program logic goes here
begin
  # Example of logging within the program
  @logger.debug("Program started")
  db_config = YAML.load_file('config/database.yml')['development']
  db = Database.new(db_config, @logger)
  # test_db = TestDatabase.new(db_config)
  # test_db.setup_test_data
  app = GUI.new(db, @logger)
  app.run
  #after all
  # test_db.clear_test_data
  # Simulate your program logic here...

rescue StandardError => e
  # Log any exceptions that occur during execution
  @logger.error("An error occurred: #{e.message}")
  raise e  # Re-raise the exception after logging it
end