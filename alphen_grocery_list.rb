# alphen_grocery_list.rb
require 'sinatra'
require 'mongo'
require 'haml'

include Mongo
use Rack::MethodOverride #required for Sinatra PUT and DELETE methods (browser hack)

DB = Connection.new(ENV['DATABASE_URL'], ENV['DATABASE_URL_PORT'].to_i || 'localhost').db('grocery_list')
if ENV['DATABASE_USER'] && ENV['DATABASE_PASSWORD']
  auth = DB.authenticate(ENV['DATABASE_USER'], ENV['DATABASE_PASSWORD'])
end

configure :production do
  enable :raise_errors
end

# Routes
get '/' do
  haml :create
end

post '/' do
  create_list params[:list_name]
end

get '/:list_id' do
  @list_id = params[:list_id]
  haml :list
end

post '/:list_id' do
  @list_id = params[:list_id]
  save_item @list_id, params[:grocery_item]
end

delete '/:list_id/:list_item' do
  @list_id = params[:list_id]
  @list_item = params[:list_item]
  delete_item @list_id, @list_item
end

# Helpers 
helpers do
  def create_list(list_name)
    lists_collection = DB["lists"]
    list_doc = {"name" => "#{list_name}"}
    if list_id = lists_collection.insert(list_doc)
      redirect "/#{list_id}"
    end
  end

  def get_list(list_id)
    DB["lists"].find("_id" => BSON::ObjectId(list_id)).each do |list|
      redirect "/#{list_id}"
    end
  end

  def get_list_name(list_id)
    list_name = ''
    DB["lists"].find("_id" => BSON::ObjectId(list_id)).each do |list|
      list_name = list["name"]
    end
    list_name
  end

  def get_all_lists 
    html = ''
    DB["lists"].find().each do |list|
      html += "<li><a title='#{list["name"]}' href='/#{list["_id"]}'>#{list["name"]}</a></li>\n"
    end
    html
  end

  def get_items(list_id)
    html = ''
    DB["lists"].find("_id" => BSON::ObjectId(list_id)).each do |list|
      #html += "#{list.inspect}"
      if list["items"]
        list["items"].each do |list_item|
          html += <<-HTML
              <li class="list_item">
                <form method="post" action="/#{list_id}/#{list_item}">
                  <span class="list_text">#{list_item}</span>
                  <input type="hidden" name="_method" value="delete" />
                  <input class="list_delete" type="submit" value="delete">
                </form>
              </li>\n
            HTML
        end
      end
    end
    html
  end

  def save_item(list_id, item_value)
    if item_value
      lists = DB["lists"]
      lists.update( { "_id" => BSON::ObjectId(list_id) }, { "$addToSet" => { "items" => item_value } } )
      #lists.update( { "_id" => BSON::ObjectId(list_id) }, { "$addToSet" => { "items" => item_value } } )
    end
    redirect "/#{list_id}"
  end

  def delete_item(list_id, list_item)
    if list_item
      lists = DB["lists"]
      lists.update( { "_id" => BSON::ObjectId(list_id) }, { "$pull" => { "items" => list_item } } )
    end
    redirect "/#{@list_id}"
  end

  def complete_item(list_id, list_item)
    if list_item
      lists = DB["lists"]
      lists.update( { "_id" => BSON::ObjectId(list_id) }, { "$pull" => { "items" => list_item } } )
    end
    redirect "/#{@list_id}"
  end
end
