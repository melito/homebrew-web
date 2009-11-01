require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Branch do
  
  before(:all) do
    DB.keys.each {|x| DB.out(x) }
    @branch = Branch.create(:name => "master")
  end
    
  it "should let me create a new branch" do
    branch = Branch.new(:name => "contributions")
    branch.should_not be_nil
    branch.name.should eql 'contributions'
    branch.save.should be_false
  end
  
  it "should let me find all branches" do
    Branch.should respond_to(:all)
    Branch.all.should_not be_nil
    Branch.all.should_not be_empty
    Branch.all.should eql ['master', 'contributions']
  end
  
  it "should have a formulas method" do
    @branch.should respond_to(:formulas)
  end
  
  it "should allow me to add formulas" do
    formula = Formula.new(:name => "money")
    @branch.add_formula(formula).should be_true
  end
  
  it "should be able to find those new formulas" do
    @branch.formulas.should_not be_nil
    @branch.formulas.should_not be_empty
    @branch.formulas.should eql ['money']
  end
    
end