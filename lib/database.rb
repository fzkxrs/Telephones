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
  def search_employee(enterprise, department, group, lab, fio, tel)
    # Query the database
    if tel && fio
      enterprise = nil
      department = nil
      group = nil
      lab = nil
    end
    if tel
      enterprise = nil
      department = nil
      group = nil
      lab = nil
      fio = nil
    end
    if fio
      enterprise = nil
      department = nil
      group = nil
      lab = nil
      tel = nil
    end
    query = <<-SQL
      SELECT 
        d.enterprise, 
        d.department, 
        d."group", 
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
        (d.inner_tel = $6 OR d.corp_inner_tel = $6)
        OR (d.fio = $5) 
        OR (
          d.enterprise = $1 AND
          d.department = $2 AND
          d."group" = $3 AND
          d.lab = $4 AND
          d.fio = $5
        )
      ORDER BY d.enterprise ASC;
    SQL

    execute_query(query, enterprise, department, group, lab, fio, tel)
  end

  private

  # Method to execute SQL query and return result
  def execute_query(query, *args)
    # Ensure the connection is valid before executing the query
    open_connection
    if @connection
      begin
        result = @connection.exec_params(query, args)
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