class MassObject
  def self.set_attrs(*attributes)
    @attributes = attributes
    attributes.each do |attr|
      self.send(:attr_accessor, attr) 
    end
  end

  def self.attributes
    @attributes
  end

  def self.parse_all(results)
    results = results.map do |hash| 
      self.new(hash)
    end
    results.count == 1 ? results.first : results
  end

  def initialize(params = {})
    params.each do |attr_name, value|
      if self.class.attributes.include?(attr_name.to_sym)
        attr_equals = "#{attr_name}=".to_sym
        self.send(attr_equals, value)
      else
        raise "mass assignment to unregistered attribute '#{attr_name}'"
      end
    end
  
  end
end






