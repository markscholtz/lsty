# alphen_grocery_list.rb
require 'sinatra'
require 'mongo'
require 'haml'

# Routes
get '/' do
  haml :home
end

get '/blah' do
  blah
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
end
