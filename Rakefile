$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'models'))
require File.join(File.dirname(__FILE__), 'vendor', 'gems', 'environment')

require "tokyocabinet"
require "open-uri"
require "json"
require "grit"
require "pp"
include TokyoCabinet
include Grit

require "model"

HOMEBREW_LOCATION = `brew --prefix`.chomp!

def format_url(url)
  url.gsub(/^(http)(.+)/, 'git\2.git')
end

def in_homebrew
  Dir.chdir(HOMEBREW_LOCATION) do |hb|
    yield
  end
end

namespace :network do

  task :get_members do
    @members = JSON.parse(open("http://github.com/mxcl/homebrew/network/members.json").read)["users"]    
  end
  
  desc "Prints out all members in the homebrew network"
  task :ls => [:get_members] do
    @members.each do |member|
      login = member['owner']['login']
      url   = member['url']
      git_url = format_url(url)
      puts "== #{login}"
      puts "   #{url}"
      puts "   #{git_url}"
    end
  end

  namespace :remotes do
    desc "List all remotes for your homebrew installation"
    task :ls do
      in_homebrew { puts `git remote -v` }
    end
    
    desc "Add a user from the network as a remote (ex: rake network:remotes:add[mxcl])"
    task :add, [:user] => [:get_members] do |t, args|
      hit = 0
      @members.each do |member|
        next unless args.user == member['owner']['login']
        in_homebrew {
          `git remote add #{args.user} #{format_url(member['url'])}`
        }
        hit = 1
      end
      puts "Network member #{args.user} not found, remote not added" if hit == 0
    end
    
    # FIXME: I live in Seattle.  Its never dry here.
    desc "Add all users from network as remotes and fetch (non-destructive)"
    task :add_all => [:get_members] do
      current_remotes = []
      in_homebrew do 
        current_list = `git remote -v` 
        current_list.each_line {|l| current_remotes << l.split(' ').first }
      end
      current_remotes.uniq!
      @members.each do |member|
        user = member['owner']['login']
        url  = member['url']
        
        next if current_remotes.include?(user)
        in_homebrew { `git remote add #{user} #{format_url(url)}`}
        puts "Added: #{user} #{format_url(url)}"
      end      
    end
    
    # FIXME: Raindrops keep falling on my head
    desc "Fetches (non-destructive) from all your remotes. Use network:remotes:add_all prior for greater effect."
    task :fetch do
      current_remotes = []
      in_homebrew do
        current_list = `git remote -v`
        current_list.each_line {|l| current_remotes << l.split(' ').first }
      end
      current_remotes.uniq!
      current_remotes.each do |remote|
        in_homebrew { `git fetch #{remote}` }
      end
    end
    
    # FIXME: I could use a towel here
    desc "Remove all remotes (except origin) from your homebrew install"
    task :remove_all do
      current_remotes = []
      in_homebrew do
        current_list = `git remote -v`
        current_list.each_line {|l| current_remotes << l.split(' ').first }
      end
      current_remotes.uniq!
      current_remotes.each do |remote|
        next if remote == "origin"
        in_homebrew { `git remote rm #{remote}` }
      end
    end
    
  end
      
end

namespace :homebrew do
  
  desc "Prints location where homebrew is installed"
  task :location do
    puts "Homebrew is installed in: #{HOMEBREW_LOCATION}"
  end
  
end

namespace :db do
  
  desc "Builds a TokyoCabinet BDB database to help search the git repo faster"
  task :build do
    DB = BDB::new  # B-Tree database; keys may have multiple values
    DB.open("test.bdb", BDB::OWRITER | BDB::OCREAT)
    @repo = Repo.new(HOMEBREW_LOCATION)
    
    @repo.remotes.each do |remote|
      user, branch = remote.name.split('/')
      next if user == "origin"      
      puts "Indexing: #{remote.name}"
      
      @repo.tree(remote.name, ["Library/Formula"]).contents.first.contents.each do |pkg|
        formula = pkg.name.chomp('.rb')
        DB.putdup(remote.name, formula)
      end
    end
    
  end
  
end
