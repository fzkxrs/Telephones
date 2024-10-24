# app.rb
require 'English'
require 'logger'
require 'yaml'
require_relative 'gui'
require_relative 'database'
require_relative 'test_database'

class App
  def initialize
    log_file = 'application.log'
    @logger = Logger.new(log_file)
    @logger.level = Logger::DEBUG

    # Log an example message
    @logger.info('Program initialized')

    at_exit do
      handle_exit(log_file)
    end
  end

  def run
    begin
      @logger.debug('Program started')

      # Load database configuration
      db_config = YAML.load_file('config/database.yml')['development']
      db = Database.new(db_config, @logger)

      # Initialize and run the GUI
      app = GUI.new(db, @logger)
      app.run

    rescue StandardError => e
      # Log any exceptions that occur during execution
      @logger.error("An error occurred: #{e.message}")
      raise e
    end
  end

  private

  def handle_exit(log_file)
    @logger.info('Program exited as expected')
    @logger.close

    if $ERROR_INFO.nil?
      begin
        # Clear the log file on a successful exit
        File.truncate(log_file, 10_000)
      rescue Errno::EACCES => e
        @logger.error("Error truncating log file: #{e.message}")
      end
    else
      @logger.error("Program exited with an error: #{$ERROR_INFO.message}")
    end
  end
end
