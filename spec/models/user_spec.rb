require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe User do
  
  before(:all) do
    DB.vanish
    @user = User.create(:name => "melito")
  end
    
  it "should let me create a new user" do
    user = User.new(:name => "mxcl")
    user.should_not be_nil
    user.name.should eql 'mxcl'
    user.save.should be_true
  end
  
  it "should let me find all users" do
    User.should respond_to(:all)
    User.all.should_not be_nil
    User.all.should_not be_empty
    User.all.should eql ['melito', 'mxcl']
  end

  it "should have a branches method" do
    @user.should respond_to(:branches)
  end

  it "should be able to create branches" do
    @user.should respond_to(:add_branch)
    branch = Branch.new(:name => "master")
    @user.add_branch(branch).should be_true
  end  
  
  it "should be able to get all those branches back" do
    @user.branches.should_not be_nil
    @user.branches.should_not be_empty
  end
      
end