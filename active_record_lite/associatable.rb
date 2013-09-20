require 'active_support/core_ext/object/try'
require 'active_support/inflector'
require_relative './db_connection.rb'

class AssocParams
  def other_class
  end

  def other_table
  end
end

class BelongsToAssocParams < AssocParams

  attr_reader :primary_key, :foreign_key
  def initialize(name, params)
    defaults = {
      :class_name => name.to_s.camelize,
      :primary_key => 'id',
      :foreign_key => "#{name}_id"
    }
    params = defaults.merge(params)
    @primary_key = params[:primary_key].to_s
    @foreign_key = params[:foreign_key].to_s
    @other_class_name = params[:class_name]
  end
  
  def other_table
    self.other_class.table_name
  end
  
  def other_class
    @other_class_name.constantize  
  end


  def type
  end
end

class HasManyAssocParams < AssocParams

  attr_reader :primary_key, :foreign_key
  
  def initialize(name, params, self_class)
    defaults = {
      :class_name => name.to_s.singularize.camelize,
      :primary_key => 'id',
      :foreign_key => "#{self.to_s.underscore}_id"
    }
    params = defaults.merge(params)

    @primary_key = params[:primary_key].to_s
    @foreign_key = params[:foreign_key].to_s
    @other_class_name  = params[:class_name]
    @other_table = other_class.table_name
    @own_table = self_class.table_name
  
  end
  
  def other_table
    self.other_class.table_name
  end
  
  def other_class
    @other_class_name.constantize  
  end

  def type
  end
end

module Associatable
  def assoc_params
    @assoc_params ||= {}
  end
  
   def belongs_to(name, params = {})
     assoc_params[name] = params
     aps = BelongsToAssocParams.new(name, params)
     define_method(name) do #how do I do this without a join?
    
      result = DBConnection.execute( <<-SQL, self.send(aps.foreign_key) )
        SELECT
          #{aps.other_table}.*
        FROM
          #{aps.other_table}
        WHERE #{aps.other_table}.#{aps.primary_key} = ?
      SQL
      aps.other_class.parse_all(result)    
    end
  end

  def has_many(name, params = {})
    aps = HasManyAssocParams.new(name, params, self)
   
    define_method(name) do
      result = DBConnection.execute( <<-SQL, self.send(aps.primary_key) )
        SELECT
          #{aps.other_table}.*
        FROM
          #{aps.other_table}
        WHERE #{aps.other_table}.#{aps.foreign_key} = ?

      SQL
      aps.other_class.parse_all(result)    
    end
  
  end

  def has_one_through(name, assoc1, assoc2)
    define_method(name) do
      assoc1aps = BelongsToAssocParams.new(name, self.class.assoc_params[assoc1])
      assoc2aps = BelongsToAssocParams.new(name, assoc1aps.other_class.assoc_params[assoc2])
      result = DBConnection.execute( <<-SQL, self.send(assoc1aps.foreign_key))
        SELECT
          #{assoc2aps.other_table}.*  
        FROM
          #{assoc1aps.other_table}
        JOIN
          #{assoc2aps.other_table}
        ON #{assoc1aps.other_table}.#{assoc2aps.foreign_key} = #{assoc2aps.other_table}.#{assoc2aps.primary_key}  
        WHERE #{assoc1aps.other_table}.#{assoc1aps.primary_key} = ?
      SQL
        
        
      assoc2aps.other_class.parse_all(result)
    end
  end

end
