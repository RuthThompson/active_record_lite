require './../active_record_lite.rb'

# https://tomafro.net/2010/01/tip-relative-paths-with-file-expand-path
cats_db_file_name =
  File.expand_path(File.join(File.dirname(__FILE__), "cats.db"))
DBConnection.open('../../test/cats.db')

class Cat < SQLObject
  set_table_name("cats")
  set_attrs(:id, :name, :owner_id)
  belongs_to(:human,
             :class_name => "Human",
             :primary_key => :id,
             :foreign_key => :owner_id
             )
             
  has_one_through(:house, :human, :house)
end

class Human < SQLObject
  set_table_name("humans")
  set_attrs(:id, :fname, :lname, :house_id)
  has_many(:cats, 
           :class_name => "Cat",
           :primary_key => :id,
           :foreign_key => :owner_id
           )
           
  belongs_to(:house,
             :class_name => "House",
             :primary_key => :id,
             :foreign_key => :house_id
             )
end

class House < SQLObject
  set_table_name("houses")
  set_attrs(:id, :address, :house_id)
  
  
end

# p Human.find(1)
# p Cat.find(1)
# p Cat.find(2)
# 
# p Human.all
# p Cat.all

# c = Cat.new(:name => "Gizmo", :owner_id => 1)
# c.save # create
# c.save # update
