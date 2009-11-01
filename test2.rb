require "rubygems"
require "tokyocabinet"
require "pp"
include TokyoCabinet

DB = BDB::new  # B-Tree database; keys may have multiple values
DB.open("test.bdb", BDB::OWRITER | BDB::OCREAT)
d = BDBCUR::new(DB)

results = []

d.first
while key = d.key
  results << {d.key => d.val} if d.val =~ /rub/
  d.next
end

pp results