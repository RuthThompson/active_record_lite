require 'sqlite3'

class DBConnection
  def self.open(db_file_name = '../../test/cats.db')
    @db = SQLite3::Database.new(db_file_name)
    @db.results_as_hash = true
    @db.type_translation = true
  end

  def self.execute(*args)
    #self.open if @db.nil? #probably want to take this out so it is more flexible
    @db.execute(*args)
  end

  def self.last_insert_row_id
    @db.last_insert_row_id
  end

  private
  def initialize(db_file_name)
  end
end
