require 'spec_helper'

describe CadBot do
  
  describe "#initialize" do
    context "default configurations" do
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
    
    context "custom configurations" do
      it "can take a new configuration file location instead of the default" do
        custom_config_file = CadBot.root + "spec/fixtures/bot.yml"
        config_yaml = File.open(custom_config_file, "r") { |f| YAML::load(f) }
        @bot = CadBot.new(:config_file => custom_config_file)
        @bot.config.should == config_yaml
      end
      
      it "can take a block for additional configs" do
        @bot = CadBot.new do
          def test_method
            "foo"
          end
        end
        @bot.should respond_to(:test_method)
        @bot.test_method.should == "foo"
      end
      
      it "can specify not to use a configuration file" do
        @bot = CadBot.new(:config_file => false)
        @bot.config.should == {}
      end
    end
  end
  
  describe "#load_plugins" do
    it "loads all plugins to the PluginSet" do
      @bot = CadBot.new(:config_file => false, :plugins => { :path => (CadBot.root + "spec/fixtures/plugins/") })
      @bot.plugins.plugins.should == [BotSnack]
    end
  end
  
  it "should have a version" do
    CadBot::VERSION.should_not be_nil
  end
end