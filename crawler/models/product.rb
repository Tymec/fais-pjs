require "sequel"

class Product < Sequel::Model
  def before_create
    super
    self.created_at = Time.now
  end

  def inspect
    "#<Product name=#{name} price=#{price} url=#{url}>"
  end
end
