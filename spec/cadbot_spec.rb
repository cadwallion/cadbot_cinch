require 'spec_helper'

describe CadBot do
  
  describe "#initialize" do
    before(:each) do
      @bot = CadBot.new
    end
    
    it "loads configuration YAML" do
      @bot.config.should_not be_nil
      @bot.config.should == File.open(CadBot.root + "/config/bots.yml", "r") { |f| YAML::load(f) }
    end
    
    it "creates a CadBot::PluginSet" do
      @bot.plugins.should be_instance_of(CadBot::PluginSet)
    end
  end
  
  it "should have a version" do
    CadBot::VERSION.should_not be_nil
  end
end