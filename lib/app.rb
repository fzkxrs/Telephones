require_relative './gui'
require_relative './database'


conn = Database.new('postgres', 'postgres', '1144')
app = GUI.new(conn)
app.run