require 'pg'

class Database
  def initialize(dbname, user, password)
    @connection = PG.connect(dbname: dbname, user: user, password: password)
    @employees_table_name = "data"
  end

  public
  def search_employee(fio="null")
    # Query the database
    query = <<-SQL
            SELECT 
              enterprise, 
              department 
            FROM 
              employees.#{@employees_table_name}
            WHERE 
              fio = $1 
            ORDER BY 
              enterprise ASC;
          SQL
    execute_query(query, fio)
  end

  private
  # Method to execute SQL query and return result
  def execute_query(query, fio)
    begin
      result = @connection.exec_params(query, [fio])
      return result
    rescue PG::Error => e
      puts "Database error: #{e.message}"
      return nil
    end
  end

  def close
    self.close_connection
  end
end