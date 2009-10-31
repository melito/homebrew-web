require "rubygems"
require "sinatra"
require "sequel"
require "pp"

HOMEBREW_LOCATION = `brew --prefix`.chomp!
DB = Sequel.connect("sqlite://dev.db")

require "models/all"

helpers do
  def partial(template, options={})
    options.merge!(:layout => false)
    if collection = options.delete(:collection) then
      collection.inject([]) do |buffer, member|
        buffer << erb(template.to_sym, options.merge(:layout => false, :locals => {template.to_sym => member}))
      end.join("\n")
    else
      erb(template.to_sym, options)
    end
  end
  
  def run_in_homebrew
    Dir.chdir(HOMEBREW_LOCATION) do
      yield
    end
  end
  
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

get '/checkout/:id' do
  @formula = Formula[params['id']]
  run_in_homebrew {
    cmd = "git checkout #{@formula.branch_path} Library/Formula/#{@formula.name}.rb"
    if system(cmd)
      "Successfully checked out formula"
    else
      "<img src='/images/fail.png' />"
    end
  }
end

get '/install/:id' do
  @formula = Formula[params['id']]
  run_in_homebrew {
    cmd = "git checkout #{@formula.branch_path} Library/Formula/#{@formula.name}.rb"
    if system(cmd)
      cmd = %Q{osascript -e 'tell app "Terminal" to do script "brew install #{@formula.name}"'}
      if system(cmd)
        "Successfully opened terminal window.  It's in Terminal.app's hands now."
      end
    else
      "<img src='/images/fail.png' />"
    end
  }
end