require File.join(File.dirname(__FILE__), 'vendor', 'gems', 'environment')

require "sinatra"
require "tokyocabinet"
require "yajl/json_gem"
require "grit"
include TokyoCabinet
include Grit

HOMEBREW_LOCATION = `brew --prefix`.chomp!
DB = BDB::new
DB.open("repo.bdb", BDB::OWRITER | BDB::OCREAT)   
DBC = BDBCUR::new(DB)
REPO = Repo.new(HOMEBREW_LOCATION)

helpers do
  
  def search_for(pkg)
    results =[]
    DBC.first
    while key = DBC.key
      results <<  [DBC.key, DBC.val].join(':') if DBC.val =~ Regexp.new(pkg)
      DBC.next
    end
    return results
  end
  
  def in_homebrew
    Dir.chdir(HOMEBREW_LOCATION) do |hb|
      yield
    end
  end
  
end

get '/' do
  erb :index
end

get '/search' do
  content_type :json
  
  results = search_for(params['query'])
  {
    :query => params['query'],
    :suggestions => results,
    :data => results
  }.to_json
end

get '/preview' do
  tree = params['tree']
  formula = params['formula']
  (REPO.tree(tree, ["Library/Formula"]).contents.first/"#{formula}.rb").data
end

get '/install' do
  tree = params['tree']
  formula = params['formula']
  puts "HIT"
  in_homebrew {
    `git checkout #{tree} Library/Formula/#{formula}.rb`
    `osascript -e 'tell app "Terminal" to do script "brew install #{formula}"'`
  }
  
end

# FIXME: lol, sinatra won't call this
trap("INT") {
  #DB.close
}

__END__

@@ layout
<html>
  <head>
    <title>Homebrew</title>
    <script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.3/jquery.min.js"></script>
		<script src="http://www.devbridge.com/projects/autocomplete/jquery/local/scripts/jquery.autocomplete.js" type="text/javascript"></script>
    
     <script type="text/javascript" charset="utf-8">
       $(document).ready(function(){
       
         var preview_formula = function(path){
          var tree     = path.split(':')[0];
          var formula  = path.split(':')[1];
          $.get('/preview', 
                {"tree": tree,
                 "formula": formula},
                 function(data){ 
                   $("#preview_box").text(data);
                   $("#formula_preview").show();
                 },
                 "text"
          );     
         }
       
         var install_formula = function(path){
          var tree     = path.split(':')[0];
          var formula  = path.split(':')[1];
          $.get('/install', 
                {"tree": tree,
                 "formula": formula},
                 function(data){},
                 "text"
          );     
         }
    
         var a = $('#search').autocomplete({ 
             serviceUrl:'/search',
             minChars:2, 
             maxHeight:500,
             width:400,
             zIndex: 9999,
             deferRequestBy: 0, //miliseconds
             onSelect: function(value, data){ 
               $("input#current_formula").val(data);
               preview_formula(data);
             },
         });
        
        $("input#install").click(function(){
          alert("Installing " + $("#current_formula").val());
          install_formula($("#current_formula").val());
        });     
          
      });
    </script>
    
    <style type="text/css" media="screen">
      * { padding:0; margin:0; }
      body { background:#efefef; }
      #wrapper { padding:2em; border:1px solid #666; }
      input { border:1px solid #999; font-size:2em;}
      .control { padding:1em; }
      .button_controls { padding:0 5px 0 5px;}
      #preview_box { border:1px solid #999; }
      /* Autocomplete: */
      .autocomplete-w1 { position:absolute; top:0px; left:0px; margin:8px 0 0 6px;}
      .autocomplete { border:1px solid #999; background:#FFF; cursor:default; text-align:left; max-height:350px; overflow:auto; margin:-6px 6px 6px -6px; /* IE6 specific: */ _height:350px;  _margin:0; _overflow-x:hidden; }
      .autocomplete .selected { background:#F0F0F0; }
      .autocomplete div { padding:2px 5px; white-space:nowrap; }
      .autocomplete strong { font-weight:normal; color:#3399FF; }
      .autocomplete .selected { background:red; }
    </style>
  </head>
  
  <body>
    <%= yield %>
  </body>
  
</html>

@@ index
<div id="wrapper">
  <div class="control">
    <h1 id="search_for_formulas">Search for Formulas</h1>
    <input type="text" name="search" value="" id="search">
  </div>

  <div id="formula_preview" style="display:none;">
    <textarea id="preview_box" rows='30' cols='80'></textarea>

    <div class="control">
      <input type="button" name="install" value="Install" id="install" class='button_controls'>
      <input type="hidden" name="current_formula" value="" id="current_formula">
    </div>
  </div>  
</div>
