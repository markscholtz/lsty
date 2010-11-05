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

post '/' do
  login_user params[:username], params[:password]
end

get '/register' do
  haml :register
end

post '/register' do
  create_user params[:username], params[:password]
  redirect "/users/#{params[:username]}"
end

get '/users/:user' do
  @user = params[:user]
  haml :user
end

post '/users/:user' do
  @user = params[:user]
  create_list params[:list_name], params[:user]
  redirect "/users/#{@user}/lists/#{params[:list_name].gsub(" ", "_")}"
end

get '/users/:user/lists/:list' do
  @user = params[:user]
  @list = params[:list]
  haml :list
end

post '/users/:user/lists/:list' do
  @user = params[:user]
  @list = params[:list]
  save_item @user, @list, params[:grocery_item]
  redirect "/users/#{@user}/lists/#{@list}"
end

# Helpers 
helpers do
  def login_user(user, password)
    DB["users"].find("user" => user, "password" => password).each do |login_success|
      redirect "/users/#{user}"
    end
    redirect '/'
  end

  def get_items(list, user)
    html = ''
    DB["lists"].find("name" => list, "user" => user).each do |item|
      #html += "#{item.inspect}"
      if item["items"]
        item["items"].each do |list_item|
          html += "<li>#{list_item}</li>\n"
        end
      end
    end
    html
  end

  def get_lists(user)
    @user = user
    html = ''
    DB["lists"].find("user" => @user).each do |list|
      #html += "#{list.inspect}"
      html += <<-HTML 
          <li>
            <a title=#{list["name"]} href="/users/#{@user}/lists/#{list["name"]}">#{list["name"].gsub("_"," ")}</a>
          </li>\n
        HTML
    end
    html
  end

  def create_user(user, password)
    users_collection = DB["users"]
    user_doc = {"user" => user, "password" => password}
    users_collection.insert(user_doc)
  end

  def save_item(user, list_name, item_value)
    if item_value
      lists = DB["lists"]
      #list = lists.find("name" => list_name, "user" => user)
      lists.update( { "name" => list_name, "user" => user }, { "$addToSet" => { "items" => item_value } } )
    end
  end

  def create_list(list_name, user)
    lists_collection = DB["lists"]
    list_doc = {"name" => "#{list_name.gsub(' ', '_')}", "user" => user}
    lists_collection.insert(list_doc)
  end
end
