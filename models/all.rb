class User < Sequel::Model
  one_to_many :branches
end

class Formula < Sequel::Model
  many_to_many :branches, :join_table => :branches_formulas

  def users
    self.branches.collect {|branch| branch.user }
  end

  #def branch_path
  #  "#{self.branch.user.name}/#{self.branch.name}"
  #end
  
  #def url
  #  "http://github.com/#{self.branch.user.name}/homebrew/blob/#{self.branch.name}/Library/Formula/#{self.name}.rb"
  #end
end

class Branch < Sequel::Model
  many_to_one :user
  many_to_many :formulas, :join_table => :branches_formulas
end