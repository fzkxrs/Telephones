require 'pg'
require_relative 'modules/users_db'

class Database
  include UsersDb
  attr_reader :connection

  def initialize(db_config)
    @dbname = db_config['database']
    @user = db_config['username']
    @password = db_config['password']
    @host = db_config['host']
    @data_table_name = "employees.data"
    @phones_table_name = "employees.phones"
    @users_table_name = "employees.users"

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
      puts "Connected to the database successfully!"
    else
      puts "Failed to connect to the database."
    end
  end

  # Search employee by multiple criteria
  def search_employee(enterprise, subdivision, department, lab, fio, tel)
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

    # Add wildcard for partial fio match if applicable
    # fio = "%#{fio}%" unless fio.nil? || fio.empty?

    begin
      # Call the stored procedure
      execute_query("SELECT * FROM fn_search_employee($1, $2, $3, $4, $5, $6);",
                      enterprise, subdivision, department, lab, fio, tel)
    rescue => e
      # Handle error
      puts "Error executing stored procedure: #{e.message}"
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
  def update_entry(entry_data)
    query = "CALL employees.sp_update_entry($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11);"
    execute_query(query, entry_data["id"], entry_data["enterprise"], entry_data["subdivision"],
                  entry_data["department"], entry_data["lab"], entry_data["fio"],
                  entry_data["position"], entry_data["corp_inner_tel"], entry_data["inner_tel"],
                  entry_data["email"], entry_data["address"])
  end

  # Add method to delete the entry
  def delete_entry(id)
    query = "CALL employees.sp_delete_entry($1);"
    execute_query(query, id)
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
        puts "Database error: #{e.message}"
        return nil
      ensure
        close_connection
      end
    else
      puts "Connection is nil. Could not execute the query."
    end
  end

  def close_connection
    @connection.close if @connection
  end
end