require_relative './db_connection'

module Searchable
  def self.where(params)
    where = params.map { |k, v| "#{k.to_s} = ?" }.join(" AND ")
    args = params.map{ |k, v| v }
    result = DBConnection.execute( <<-SQL, *args )
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE #{where}
    SQL
    MassObject.parse_all(result)
  end
  
end

#Q -- how would I make this stringable?  eg Kitty.where({}).where({})