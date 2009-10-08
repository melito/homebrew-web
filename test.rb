require "rubygems"
require "open-uri"
require "json"
require "grit"
require "sequel"
require "pp"
include Grit

DB = Sequel.connect("sqlite://dev.db")

DB.create_table :users do
  primary_key :id
  String :name
end rescue

DB.create_table :formulas do
  primary_key :id
  String :name
  Integer :branch_id
end rescue

DB.create_table :branches do
  primary_key :id
  String :name
  Integer :user_id
end rescue

require "models/all"

HOMEBREW_LOCATION = `brew --prefix`.chomp!

@repo = Repo.new(HOMEBREW_LOCATION)

def get_members
  @members = JSON.parse(open("http://github.com/mxcl/homebrew/network/members.json").read)["users"]
end

def add_remote(name, url="git://github.com/#{name}/homebrew.git")
  Dir.chdir(HOMEBREW_LOCATION) do
    cmd = "git remote add #{name} #{url}"
    system(cmd)
  end
end

def add_all_network_remotes
  @members.each do |member|
    login = member["owner"]["login"]
    begin
      add_remote(login)
      fetch_remote(login)
    rescue
      puts "Couldn't add/fetch #{login}"
    end
  end
end

def remove_remote(name)
  Dir.chdir(HOMEBREW_LOCATION) do
    cmd = "git remote rm #{name}"
    system(cmd) unless name == "origin"
    p :got if name == "baratrion"
  end  
end

def remove_all_network_remotes
  @members.each do |member|
    remove_remote(member["owner"]["login"])
  end  
end

def fetch_remote(remote)
  Dir.chdir(HOMEBREW_LOCATION) do
    cmd = "git fetch #{remote}"
    system(cmd)
  end  
end

def remove_branch(branch)
  Dir.chdir(HOMEBREW_LOCATION) do
    cmd = "git branch -d #{branch}"
    system(cmd) unless branch == "master"
  end  
end

def build_database_of_packages
  @repo.remotes.each do |remote|
    user, branch = remote.name.split('/')
    user = User.find_or_create(:name => user)
    ref = {:user => user, :name => branch}
    
    branch = Branch.new(ref)
    user.add_branch(branch)
    
    @repo.tree(remote.name, ["Library/Formula"]).contents.first.contents.each do |pkg|
      p pkg.name
      formula_name = pkg.name.chomp('.rb')
      formula = Formula.find_or_create(:name => formula_name)
      
      branch.add_formula(formula)
    end
  end
end

if $0 == __FILE__    
  get_members
  add_all_network_remotes
  build_database_of_packages
end