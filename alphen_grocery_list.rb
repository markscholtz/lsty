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

get '/user' do
  haml :user
end

post '/user' do
  create_list params[:list_name]
  redirect "/list/#{params[:list_name]}"
end

get '/list/:list' do
  @list = params[:list]
  haml :list
end

post '/list/:list' do
  blah = save_item params[:list], params[:grocery_item]
  redirect "/list/#{params[:list]}"
end

# Helpers 
helpers do
  def get_items(list)
    html = ''
    DB["lists"].find("name" => list).each do |item|
      html += "#{item.inspect}"
      item["items"].each do |list_item|
        html += "<li>#{list_item}</li>\n"
      end
    end
    html
  end

  def save_item(list_name, item_value)
    lists = DB["lists"]
    list = lists.find("name" => "#{list_name}")
    lists.update( { "name" => "#{list_name}" }, { "$addToSet" => { "items" => "#{item_value}" } } )
  end

  def create_list(list_name)
    lists_collection = DB["lists"]
    list_doc = {"name" => "#{list_name}"}
    lists_collection.insert(list_doc)
  end
end
