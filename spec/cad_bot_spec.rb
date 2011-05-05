require 'spec_helper'

describe CadBot do
  
  describe "#initialize" do
    context "default configurations" do
      before(:each) do
        @bot = CadBot.new(:config_file => CadBot.root + "spec/fixtures/bot.yml")
      end
      
      it "loads configuration YAML" do
        @bot.config.should_not be_nil
        @bot.config.should == File.open(CadBot.root + "spec/fixtures/bot.yml", "r") { |f| YAML::load(f) }
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
        @bot = CadBot.new(:config_file => CadBot.root + "spec/fixtures/bot.yml") do
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
      
      it "can specify no plugin directory to load manually" do
        @bot = CadBot.new(:config_file => CadBot.root + "spec/fixtures/bot.yml", :plugins => false)
        @bot.plugins.plugins.should == []
      end
      
      it "can specify plugin variables (path, suffix, prefix)" do
        @bot = CadBot.new(:config_file => CadBot.root + "spec/fixtures/bot.yml", :plugins => { :path => (CadBot.root + "spec/fixtures/plugins/") })
        @bot.plugins.plugins.should == [BotSnack]
      end
    end
  end
  
  describe "#load_plugins" do
    it "loads all plugins to the PluginSet" do
      @bot = CadBot.new(:config_file => false, :plugins => { :path => (CadBot.root + "spec/fixtures/plugins/") })
      @bot.plugins.should be_kind_of(CadBot::PluginSet)
      @bot.plugins.plugins.should == [BotSnack]
    end
  end
  
  describe "#load_networks" do
    it "calls #load_network for every network in the @config" do
      @test_config = File.open(CadBot.root + "spec/fixtures/bot.yml", "r") { |f| YAML::load(f) }
      @bot = CadBot.new(:config_file => CadBot.root + "spec/fixtures/bot.yml")
      @bot.should_receive(:load_network).exactly(@test_config["networks"].size)
      @bot.load_networks
    end
    
    it "should not call load_network if there are no networks in the @config" do
      @bot = CadBot.new(:config_file => false)
      @bot.should_not_receive(:load_network)
      @bot.load_networks
    end
  end
  
  describe "#load_network" do
    it "creates an instance of Cinch::Bot and assigns to @networks" do
      @test_config = File.open(CadBot.root + "spec/fixtures/bot.yml", "r") { |f| YAML::load(f) }
      @bot = CadBot.new(:config_file => CadBot.root + "spec/fixtures/bot.yml")
      @bot.networks[@test_config["networks"][0]["name"]].should be_instance_of(Cinch::Bot)
    end
    
    it "sends options hash to the Cinch::Bot instance" do
      @test_config = File.open(CadBot.root + "spec/fixtures/bot.yml", "r") { |f| YAML::load(f) }
      @bot = CadBot.new(:config_file => CadBot.root + "spec/fixtures/bot.yml")
      test_network = @test_config["networks"][0]
      test_network.each do |k, v|
        @bot.networks[test_network["name"]].config.send(k.to_sym).should == v
      end
    end
  end
  
  describe "#load_database" do
    before(:each) do
      CadBot::Database.disconnect
    end
    
    it "should only load a connection if configs are sent" do
      CadBot::Database.should_not_receive(:load)
      @bot = CadBot.new(:config_file => false)
    end
  end
  
  it "should have a version" do
    CadBot::VERSION.should_not be_nil
  end
end