require 'pg'

class Database
  attr_reader :connection

  def initialize(db_config)
    @dbname = db_config['database']
    @user = db_config['username']
    @password = db_config['password']
    @host = db_config['host']
    @data_table_name = "employees.data"
    @phones_table_name = "employees.phones"

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
    # Query the database
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
    query = <<-SQL
    SELECT 
      d.enterprise, 
      d.subdivision, 
      d.department, 
      d.lab, 
      d.fio, 
      d.position, 
      d.corp_inner_tel, 
      d.inner_tel, 
      d.email, 
      d.address, 
      p.phone, 
      p.fax, 
      p.modem, 
      p.mg
    FROM #{@data_table_name} AS d
    LEFT JOIN #{@phones_table_name} AS p ON d.id = p.id
    WHERE 
      (d.inner_tel = CAST($6 AS INTEGER) OR d.corp_inner_tel = CAST($6 AS INTEGER))
      OR (d.fio = $5)
      OR (
        d.enterprise = $1 AND
        d.subdivision = $2 AND
        d.department = $3 AND
        d.lab = $4 AND
        d.fio LIKE $5
      )
    ORDER BY d.enterprise ASC;
    SQL

    # Modify fio to add wildcard characters for partial matching
    fio = "%#{fio}%" unless fio.nil? || fio.empty?

    execute_query(query, enterprise, subdivision, department, lab, fio, tel)
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
    query = "SELECT password_hash FROM users WHERE username = $1"
    result = db.execute_query(query, username)
    result[0]['password_hash'] if result.any?
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
        close
      end
    else
      puts "Connection is nil. Could not execute the query."
    end
  end

  def close
    @connection.close if @connection
  end
end