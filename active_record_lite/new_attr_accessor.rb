class Object

  def self.new_attr_accessor(*attrs)
   attrs.each do |attr|
     attr_at = "@#{attr.to_s}".to_sym
     attr_equals = "#{attr.to_s}=".to_sym
     define_method(attr) do 
                           instance_variable_get(attr_at)
                         end
     
     define_method(attr_equals) do |value|
                                  instance_variable_set(attr_at, value)
                                end
     end 
   end
  
end

# class Cat
#   new_attr_accessor(:cat)
#   
#   def initialize
#    @cat = "MrWhiskers"
#   end
#   
# end