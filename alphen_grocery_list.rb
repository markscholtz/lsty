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

get '/blah' do
  #blah
  db_test
end

# Helpers 
helpers do
  def blah
    html = ''
    (1..10).each do |i|
      html += "<li>#{i}</li>\n"
    end
    html
  end

  def db_test
    collection = DB["lists"]
    doc = {"name" => "TestDoc"}
    collection.insert(doc)

    test_doc = DB['lists'].find_one()
    test_doc.inspect
  end
end
