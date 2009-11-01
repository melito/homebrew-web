require File.join(File.dirname(__FILE__), 'vendor', 'gems', 'environment')

require "sinatra"
require "tokyocabinet"
require "yajl/json_gem"
include TokyoCabinet

HOMEBREW_LOCATION = `brew --prefix`.chomp!
DB = BDB::new
DB.open("test.bdb", BDB::OWRITER | BDB::OCREAT)   
DBC = BDBCUR::new(DB)

get '/' do
  %Q{
    <div>
      
    </div>
    
  }
end

get '/search' do
  content_type :json
  results = []
  
  DBC.first
  while key = DBC.key
    results << {DBC.key => DBC.val} if DBC.val =~ Regexp.new(params['pkg'])
    DBC.next
  end
  
  results.to_json
end

__END__
@@layout
<html>
  <head>
    <title>Homebrew</title>
  </head>
  
  <body>
    <%= yield %>
  </body>
  
</html>