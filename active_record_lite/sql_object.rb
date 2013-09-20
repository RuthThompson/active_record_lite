require_relative './associatable'
require_relative './db_connection'
require_relative './mass_object'
require_relative './searchable'
require 'active_support/inflector'

class SQLObject < MassObject

  extend Searchable
  extend Associatable
  def self.set_table_name(table_name)
    @table_name = table_name
  end

  def self.all
   result = DBConnection.execute( <<-SQL  )
      SELECT
        *
      FROM
        #{self.table_name}   
   SQL
   self.parse_all(result)
  end

  def self.find(id)
    result = DBConnection.execute( <<-SQL, id )
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE id = ?
    SQL
    self.parse_all(result)
  end
     
  def self.table_name
    @table_name || self.to_s.pluralize.underscore
  end
  
  def save
    if self.send(:id).nil?
      create
    else
      update
    end
  end
  
  private

 def attribute_values_less_id
    attributes = self.class.attributes.dup
    attributes.delete(:id)
    attributes.map do |attr|
      self.send(attr)
    end
  end
  
  def column_names_less_id
    attributes = self.class.attributes.dup
    attributes.delete(:id)
    attributes.map(&:to_s).join(", ")
  end
  
  def create
    args = attribute_values_less_id
    n = args.count
    result = DBConnection.execute( <<-SQL, *args )
      INSERT INTO #{self.class.table_name}
        (#{column_names_less_id})
      VALUES
        (#{question_marks(n)})    
    SQL
    self.send(:id=, DBConnection.last_insert_row_id)
  end
  
  def question_marks(n)
    (['?']*n).join(", ")
  end

  def update
    id = self.send(:id)
    result = DBConnection.execute( <<-SQL, id )
      UPDATE #{self.class.table_name}
        SET #{update_set_values}
      WHERE id = ?   
    SQL
  end
  
  def update_set_values
    attributes = self.class.attributes.dup
    attributes.delete(:id)
    col_val_array = attributes.zip(attribute_values_less_id)
    col_val_array.map! do |k, v| 
      v = "'#{v}'" if v.is_a?(String)
      [k, v].join("=")
    end
    col_val_array.join(", ")
  end
  
end

# class Kitty < SQLObject
#   set_attrs(:id, :name, :owner_id) 
#   set_table_name('cats')
#   belongs_to(:human, {:class_name = }
# end

