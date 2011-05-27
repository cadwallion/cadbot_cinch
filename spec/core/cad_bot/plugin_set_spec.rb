require 'spec_helper'

describe CadBot::PluginSet do
  before(:each) do
    @plugin_set = CadBot::PluginSet.new
  end
  describe "#load_plugins" do
    it "uses @path to determine where to find plugins" do
      @plugin_set.path = (CadBot.root + "spec/fixtures/plugins/")
      @plugin_set.load_plugins
      @plugin_set.plugins.should == [BotSnack]
    end
    
    context "resetting plugins" do
      before(:each) do
        @plugin_set.path = (CadBot.root + "spec/fixtures/plugins/")
        @plugin_set.load_plugin(CadBot.root + "spec/fixtures/more_plugins/botsmack/bot_smack.rb")  
      end
      
      it "resets the plugin list by default" do
        @plugin_set.load_plugins
        @plugin_set.plugins.should == [BotSnack]
      end

      it "will retain the plugin list if false is passed" do
        @plugin_set.load_plugins(false)
        @plugin_set.plugins.should == [BotSmack, BotSnack]
      end
    end
  end
  
  describe "#load_plugin" do
    it "clears out old versions of the plugins before loading new ones" do
      @plugin_set.load_plugin(CadBot.root + "spec/fixtures/plugins/botsnack/bot_snack.rb")
      @plugin_set.load_plugin(CadBot.root + "spec/fixtures/plugins/botsnack/bot_snack.rb")
      @plugin_set.plugins.should == [BotSnack]
    end
    
    it "pulls only plugins that include Cinch::Plugins" do
      @plugin_set.load_plugin(CadBot.root + "spec/fixtures/plugins/fake/fake.rb")
      @plugin_set.plugins.should_not include(Fake)
    end
  end
end