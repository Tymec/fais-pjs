require 'sequel'
require 'pry'

DB_DIR = 'crawler/db'
FileUtils.mkdir_p DB_DIR

db = Sequel.sqlite("#{DB_DIR}/dev.db")
db.create_table? :products do
    primary_key :id
    String :name, null: false
    Decimal :price, null: false
    String :url, null: false
    String :brand, null: true
    String :seller, null: true
    Integer :category_id, null: true
    String :image, null: true

    DateTime :created_at
end
db.create_table? :categories do
    primary_key :id
    String :name, null: false, unique: true
    
    DateTime :created_at
end
db.create_table? :searches do
    primary_key :id
    String :query, null: false
    Integer :page, null: false
    
    DateTime :created_at
end

require_relative 'lib/crawler'
crawler = Crawler.new

crawler.crawl("macbook")
