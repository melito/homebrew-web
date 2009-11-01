class Model
  
  attr_accessor :name
  
  def initialize(attributes={})
    attributes.each do |k,v|
      self.send("#{k}=", v)
    end
  end
  
  def self.create(attributes={})
    self.new(attributes).save
  end
  
  def self.all
    DB.getlist(self.name)
  end
  
  def save
    DB.putdup(self.class.name, name)
    self
  end
  
  def self.has relationship
    singular = relationship.to_s.gsub(/e*s$/, '') # FIXME: Pro Inflector (tm)
    
    # Get all related objects
    send(:define_method, relationship) do
      relationship_key = self.class.key(key, relationship)
      p relationship_key
      DB.getlist(relationship_key)
    end
    
    # Add objects to the relationship
    send(:define_method, "add_#{singular}") do |x|
      relationship_key = self.class.key(key, relationship)
      DB.putdup(relationship_key, x.name)
    end
    
  end
  
  
  def self.key(*args)
    args.join(':')
  end
  
  def key
    self.class.key(self.class.name, name)
  end    
    
end

require File.expand_path(File.dirname(__FILE__))+"/user"
require File.expand_path(File.dirname(__FILE__))+"/branch"
require File.expand_path(File.dirname(__FILE__))+"/formula"