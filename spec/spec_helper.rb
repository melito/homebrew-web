$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'models'))
require File.join(File.dirname(__FILE__), '..', 'vendor', 'gems', 'environment')

require "spec"
require "webrat"

require "tokyocabinet"
require "model"

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'models'))
require File.join(File.dirname(__FILE__), '..', 'vendor', 'gems', 'environment')

Spec::Runner.configure do |conf|
  include TokyoCabinet
  include Webrat::Matchers
  
  DB = BDB::new  # B-Tree database; keys may have multiple values
  DB.open("test.bdb", BDB::OWRITER | BDB::OCREAT)
  
end