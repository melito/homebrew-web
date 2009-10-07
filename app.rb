require "rubygems"
require "sinatra"
require "sequel"
require "pp"

DB = Sequel.connect("sqlite://dev.db")

require "models/all"

helpers do
  
end

get '/' do
  erb :index
end

get '/formula' do
  @formulas = Formula.all
  erb "formula/index".to_sym
end

get '/formula/:id' do
  @formula = Formula[params['id']]
  erb "formula/show".to_sym
end

get '/search' do
  erb "search/index".to_sym
end

post '/search' do
  p params
  @formulas = Formula.filter(:name.like "%#{params['search']}%")
  pp @formulas
  erb "search/results".to_sym
end