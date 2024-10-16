require 'pg'
require_relative 'modules/users_db'

class Database
  include UsersDb
  attr_reader :connection

  def initialize(db_config, logger)
    @dbname = db_config['database']
    @user = db_config['username']
    @password = db_config['password']
    @host = db_config['host']
    @data_table_name = "employees.data"
    @phones_table_name = "employees.phones"
    @users_table_name = "employees.users"
    @logger = logger

    # Establish connection when initializing the class
    @connection = PG.connect(dbname: @dbname, user: @user, password: @password, host: @host)
  end

  public

  # Method to open a connection if not already open
  def open_connection
    unless @connection && !@connection.finished?
      @connection = PG.connect(dbname: @dbname, user: @user, password: @password, host: @host)
    end
  end

  def test_connection
    if @connection
      @logger.info( "Connected to the database successfully!")
    else
      @logger.error( "Failed to connect to the database.")
    end
  end

  # Search employee by multiple criteria
  def search_employee(enterprise, subdivision, department, lab, fio, tel)
    search_id = 0
    if tel
      result = execute_query("SELECT * FROM fn_find_phone_id($1);", tel)
      unless result.nil?
        search_id = result[0]["fn_find_phone_id"].to_i
      end
    end
    if search_id != 0
      enterprise = nil
      subdivision = nil
      department = nil
      lab = nil
      tel = nil
      fio = nil
    end
    # Reset unnecessary fields based on conditions
    if tel && fio
      enterprise = nil
      subdivision = nil
      department = nil
      lab = nil
    end
    if tel
      enterprise = nil
      subdivision = nil
      department = nil
      lab = nil
      fio = nil
    end
    if fio
      tel = nil
    end

    begin
      # Call the stored procedure
      execute_query("SELECT * FROM fn_search_employee($1, $2, $3, $4, $5, $6, $7);",
                    enterprise, subdivision, department, lab, fio, tel, search_id)
    rescue => e
      # Handle error
      @logger.error( "Error executing stored procedure: #{e.message}")
    end
  end

  def search_by(param)
    query = <<-SQL
        SELECT DISTINCT #{param} FROM #{@data_table_name};
    SQL
    result = execute_query(query)
    result = result.map { |row| row[param] } if result
    result
  end

  def search_by_arg(param, arg, value)
    query = <<-SQL
      SELECT DISTINCT #{param} FROM #{@data_table_name}
      WHERE "#{arg}" = $1
    SQL
    result = execute_query(query, value) # Pass the value as a parameter
    result = result.map { |row| row[param] } if result
    result
  end

  def get_stored_password_for(username)
    # Replace this with a real database query to retrieve the hashed password
    query = "SELECT password_hash FROM #{@users_table_name} WHERE username = $1"
    result = db.execute_query(query, username)
    result[0]['password_hash'] if result.any?
  end

  def set_stored_password_for(username, password_hash)
    # Replace this with a real database query to retrieve the hashed password
    query = "SELECT password_hash FROM #{@users_table_name} WHERE username = $1"
    result = db.execute_query(query, username)
    result[0]['password_hash'] if result.any?
  end

  # Add method to update the entry
  def upsert_entry(id, entry_data, phone_entries, role)
    query = "SELECT * FROM fn_upsert_entry($1::integer, $2::text, $3::text, $4::text, $5::text, $6::text, $7::text, $8::integer, $9::integer, $10::text, $11::text, $12::text, $13::integer, $14::integer);"
    result = execute_query(query,
                           id.to_i,
                           entry_data[:enterprise].to_s,
                           entry_data[:subdivision].to_s,
                           entry_data[:department].to_s,
                           entry_data[:lab].to_s,
                           entry_data[:fio].to_s,
                           entry_data[:position].to_s,
                           entry_data[:corp_inner_tel].to_i,
                           entry_data[:inner_tel].to_i,
                           entry_data[:email].to_s,
                           entry_data[:address].to_s,
                           role,
                           entry_data[:office_mobile].to_s,
                           entry_data[:home_phone].to_s)
    if result.nil?
      nil
    end
    if id.nil? || id == 0
      id = result[0]['fn_upsert_entry'].to_i
    end
    if !phone_entries.nil? && phone_entries != "{}"
      query = "CALL sp_update_phones($1, $2::integer[][]);"
      result = execute_query(query, id, phone_entries)
    end
    if result.nil?
      nil
    end
    id
  end

  # Add method to delete the entry
  def delete_entry(id)
    query = "CALL sp_delete_entry($1::integer);"
    execute_query(query, id.to_i)
    id
  end

  def upload_image_to_db(selected_image_path, id, username)
    # Use the file path directly
    photo_path = selected_image_path

    # Update or insert the employee's photo path in the database
    execute_query(
      "INSERT INTO employees.photos (id, photo_path, username) VALUES ($1, $2, $3)
     ON CONFLICT (id) DO UPDATE SET photo_path = EXCLUDED.photo_path, username = EXCLUDED.username",
      id, photo_path, username
    )

    @logger.info( "Image path uploaded successfully for employee ID #{id}")
    id
  end

  def get_image_path_by_id(id)
    # Query to retrieve the photo_path from the database by employee ID
    result = execute_query(
      "SELECT photo_path FROM employees.photos WHERE id = $1",
      id
    )

    # Check if a result was found
    if result.any?
      photo_path = result[0]['photo_path']
      @logger.info( "Image path found for employee ID #{id}: #{photo_path}")
      photo_path
    else
      @logger.error( "No image path found for employee ID #{id}")
      ""
    end
  end

  private

  # Method to execute SQL query and return result
  def execute_query(query, *args)
    # Ensure the connection is valid before executing the query
    open_connection
    if @connection
      begin
        if args.empty?
          result = @connection.exec_params(query)
        else
          result = @connection.exec_params(query, args)
        end
        return result
      rescue PG::Error => e
        @logger.error( "Database error: #{e.message}")
        return nil
      ensure
        close_connection
      end
    else
      @logger.error( "Connection is nil. Could not execute the query.")
    end
  end

  def close_connection
    @connection.close if @connection
  end
end