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

    at_exit do
      handle_exit(log_file)
    end
    @logger.info('Program initialized')
  end

  def run
    begin

      # Load database configuration
      db_config = YAML.load_file('config/database.yml')['development']
      db = Database.new(db_config, @logger)

      # Initialize and run the GUI
      app = GUI.new(db, @logger)
      app.run
      @logger.debug('Program started')

    rescue StandardError => e
      # Log any exceptions that occur during execution
      @logger.error("An error occurred: #{e.message}")
      raise e
    end
  end

  private

  def handle_exit(log_file)
    @logger.close

    if $ERROR_INFO.nil?
      begin
        # Retrieve the last 1000 lines from the log file
        last_lines = File.readlines(log_file).last(1000)

        # Overwrite the log file with only the last 1000 lines
        File.open(log_file, 'w') do |file|
          last_lines.each { |line| file.puts(line) }
        end

      rescue Errno::EACCES => e
        @logger.error("Error truncating log file: #{e.message}")
      rescue StandardError => e
        @logger.error("Unexpected error handling log file: #{e.message}")
      end
    else
      @logger.error("Program exited with an error: #{$ERROR_INFO.message}")
    end
    @logger.info('Program exited as expected')
  end
end
