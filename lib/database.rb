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

  # Search employee by multiple criteria
  def search_employee(enterprise, department, group, lab, fio, tel)
    # Query the database
    query = <<-SQL
    SELECT enterprise, department 
    FROM #{@data_table_name}
    WHERE 
      (inner_tel = $6 OR corp_inner_tel = $6) OR (
        enterprise = $1 AND
        department = $2 AND
        "group" = $3 AND
        lab = $4 AND
        fio = $5
      )
    ORDER BY enterprise ASC;
  SQL

    execute_query(query, enterprise, department, group, lab, fio, tel)
  end

  def test_connection
    if @connection
      puts "Connected to the database successfully!"
    else
      puts "Failed to connect to the database."
    end
  end

  def setup_test_data
    open_connection
    test_employees = [
      { fio: 'John Doe', enterprise: 'Some Enterprise', department: 'IT', group: 'Software', lab: 'Lab A',
        position: 'Engineer', email: 'john@example.com', address: '123 Street', corp_inner_tel: 1001, inner_tel: 2001,
        phones: [ { phone: 5551001, fax: 1111, modem: 2222, mg: 3333 } ]
      },
      { fio: 'Jane Smith', enterprise: 'Other Enterprise', department: 'HR', group: 'Admin', lab: 'Lab B',
        position: 'Manager', email: 'jane@example.com', address: '456 Avenue', corp_inner_tel: 1002, inner_tel: 2002,
        phones: [ { phone: 5551002, fax: 1112, modem: 2223, mg: 3334 } ]
      }
    ]

    begin
      @connection.transaction do |conn|
        test_employees.each do |employee|
          # Define the SQL query for inserting into the 'data' table
          insert_data_sql = 'INSERT INTO ' + @data_table_name + ' (fio, enterprise, department, "group", lab, position, email, address, corp_inner_tel, inner_tel) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10) RETURNING id;'

          # Execute the query and retrieve the employee ID
          data_result = conn.exec_params(insert_data_sql, [
            employee[:fio], employee[:enterprise], employee[:department], employee[:group],
            employee[:lab], employee[:position], employee[:email], employee[:address],
            employee[:corp_inner_tel], employee[:inner_tel]
          ])

          employee_id = data_result[0]['id']

          # Define the SQL query for inserting into the 'phones' table
          insert_phone_sql = 'INSERT INTO ' + @phones_table_name + ' (phone, fax, modem, mg, id) VALUES ($1, $2, $3, $4, $5);'

          # Insert phone numbers linked to the employee ID
          employee[:phones].each do |phone|
            conn.exec_params(insert_phone_sql, [phone[:phone], phone[:fax], phone[:modem], phone[:mg], employee_id])
          end
        end
      end
      puts "Test data has been successfully inserted."
    rescue PG::Error => e
      puts "Error inserting test data: #{e.message}"
    end
  end

  # Method to clear the test data from the 'data' and 'phones' tables
  def clear_test_data
    open_connection
    begin
      @connection.transaction do |conn|
        # Delete related rows in the 'phones' table first
        delete_phones_sql = 'DELETE FROM ' + @phones_table_name + ' WHERE id IN (SELECT id FROM ' + @data_table_name + ' WHERE fio = $1);'

        # Delete rows in 'phones' table for each test employee
        test_fios = ['John Doe', 'Jane Smith']
        test_fios.each do |fio|
          conn.exec_params(delete_phones_sql, [fio])
        end

        # Now, delete the rows in the 'data' table
        delete_data_sql = 'DELETE FROM ' + @data_table_name + ' WHERE fio = $1;'
        test_fios.each do |fio|
          conn.exec_params(delete_data_sql, [fio])
        end
      end
      puts "Test data has been successfully deleted."
    rescue PG::Error => e
      puts "Error deleting test data: #{e.message}"
    end
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
        @connection.close if @connection
      end
    else
      puts "Connection is nil. Could not execute the query."
    end
  end

  def close
    @connection.close if @connection
  end
end