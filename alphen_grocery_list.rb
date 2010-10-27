# alphen_grocery_list.rb
require 'sinatra'
require 'mongo'
require 'haml'

include Mongo

DB = Connection.new(ENV['DATABASE_URL'], ENV['DATABASE_URL_PORT'].to_i || 'localhost').db('grocery_list')
if ENV['DATABASE_USER'] && ENV['DATABASE_PASSWORD']
  auth = DB.authenticate(ENV['DATABASE_USER'], ENV['DATABASE_PASSWORD'])
end

configure :production do
  enable :raise_errors
end

# Routes
get '/' do
  haml :home
end

get '/list' do
  haml :list
end

post '/list' do
  save_item params[:grocery_item]
  haml :list
end

# Helpers 
helpers do
  def get_items
    html = ''
    DB["groceries"].find().each do |item|
      html += "<li>#{item["item"]}</li>\n"
    end
    html
  end

  def save_item(item)
    groceries_collection = DB["groceries"]
    grocery_doc = {"item" => "#{item}"}
    groceries_collection.insert(grocery_doc)
  end
end
