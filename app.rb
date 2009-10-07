require "rubygems"
require "sinatra"
require "sequel"

DB = Sequel.connect("sqlite://dev.db")
class Formula < Sequel::Model
  one_to_many :branches, :class => :Branch
end

class Branch < Sequel::Model
  many_to_one :formula
end

get '/' do
  @formulas = Formula.all
  erb %Q{
    
    <% for formula in @formulas %>
      <div><a href='/formula/<%= formula.id %>'><%= formula.name %></a></div>
    <% end %>
    
  }  
end

get '/formula/:id' do
  @formula = Formula[params['id']]
  p params
  
  erb %Q{
    
    <%= @formula.name %>
    <% for branch in @formula.branches %>
      <div><%= branch.user %> / <%= branch.name %></div>
    <% end %>
    
  }
end

get '/my' do
  @branch = Branch.find(:user => "origin", :name => "master")
  
  erb %Q{
    
    <%= @branch.user %> - <%= @branch.name %>
    <% for formula in @branch.formula %>
      <%= formula.last %>
    <% end %>
    
  }
  
end