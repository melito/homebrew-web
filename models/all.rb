class User < Sequel::Model
  one_to_many :branches, :class => :Branch
end

class Formula < Sequel::Model
  many_to_one :branch
  
  def branch_path
    "#{self.branch.user.name}/#{self.branch.name}"
  end
  
  def url
    "http://github.com/#{self.branch.user.name}/homebrew/blob/#{self.branch.name}/Library/Formula/#{self.name}.rb"
  end
  
  
end

class Branch < Sequel::Model
  many_to_one :user
  one_to_many :formulas, :class => :Formula
end
