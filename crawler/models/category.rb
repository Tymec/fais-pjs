require "sequel"

class Category < Sequel::Model
  def before_create
    super
    self.created_at = Time.now
  end
  
  def inspect
    "#<Category name=#{name}>"
  end
end
