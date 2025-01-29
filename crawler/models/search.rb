require "sequel"

class Search  < Sequel::Model(:searches)
  def before_create
    super
    self.created_at = Time.now
  end

  def inspect
    "#<Search query=#{query} page=#{page}>"
  end
end