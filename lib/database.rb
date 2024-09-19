require 'pg'

class Database
  def initialize(db_config)
    @adapter = db_config['adapter']
    @dbname = db_config['database']
    @user = db_config['username']
    @password = db_config['password']
    @host = db_config['host']
    @data_table = "data"
    @phones_table = "phones"
  end

  public
  def search_employee(fio, enterprise, department, group, lab, position, corp_inner_tel, inner_tel)
    # Construct the query to search both tables
    query = <<-SQL
      SELECT 
        data.id,
        data.fio,
        data.enterprise,
        data.department,
        data.group,
        data.lab,
        data.position,
        data.email,
        data.address,
        data.corp_inner_tel,
        data.inner_tel,
        phones.phone,
        phones.fax,
        phones.modem,
        phones.mg
      FROM 
        employees.#{@data_table} AS data
      LEFT JOIN 
        employees.#{@phones_table} AS phones
      ON 
        data.id = phones.id
      WHERE
        (data.fio ILIKE $1 OR $1 IS NULL)
        AND (data.enterprise ILIKE $2 OR $2 IS NULL)
        AND (data.department ILIKE $3 OR $3 IS NULL)
        AND (data.group ILIKE $4 OR $4 IS NULL)
        AND (data.lab ILIKE $5 OR $5 IS NULL)
        AND (data.position ILIKE $6 OR $6 IS NULL)
        AND (data.corp_inner_tel = $7 OR $7 IS NULL)
        AND (data.inner_tel = $8 OR $8 IS NULL)
      ORDER BY 
        data.enterprise ASC;
    SQL

    execute_query(query, fio, enterprise, department, group, lab, position, corp_inner_tel, inner_tel)
  end

  private
  # Method to execute SQL query and return result
  def execute_query(query, *args)
    @connection = PG.connect(dbname: @dbname, user: @user, password: @password,  host: @host)
    begin
      result = @connection.exec_params(query, args)
      @connection.close
      return result
    rescue PG::Error => e
      puts "Database error: #{e.message}"
      return nil
    end
  end

  def close
    @connection&.close
  end
end