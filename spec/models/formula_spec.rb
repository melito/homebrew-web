require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Formula do
  before(:all) do
    DB.vanish
    @formula = Formula.create(:name => "ruby")
  end
    
  it "should let me create a new formula" do
    formula = Formula.new(:name => "python")
    formula.should_not be_nil
    formula.name.should eql 'python'
    formula.save.should be_true
  end
  
  it "should let me find all formulas" do
    Formula.should respond_to(:all)
    Formula.all.should_not be_nil
    Formula.all.should_not be_empty
    Formula.all.should eql ['ruby', 'python']
  end

    
end