require 'bcrypt'

module UsersDb
  @role_default = "moderator"
  @users_table_name = "employees.users"

  public

  def create_user(username, password)
    password_hash = BCrypt::Password.create(password)
    query = <<-SQL
    INSERT INTO #{@users_table_name} (username, password_hash, role) VALUES ($1, $2, $3)
    SQL
    result = execute_query(query, username, password_hash, @role_default)
    result.nil?
  end

  def authenticate_user(username, password)
    query = <<-SQL
    SELECT password_hash, role, username FROM employees.users WHERE username = $1
    SQL
    result = execute_query(query, username)

    if result.any?
      stored_password = result[0]['password_hash']
      if BCrypt::Password.new(stored_password) == password
        return result[0]['role'], result[0]['username'] # Authentication success
      end
    end
    false # Authentication failed
  end
end
