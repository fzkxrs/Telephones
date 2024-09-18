require_relative './gui'
require_relative './database'

db = Database.new('postgres', 'postgres', '1144')
app = GUI.new(db)
app.run