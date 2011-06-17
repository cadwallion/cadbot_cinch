require 'spec_helper'

load_plugin("sed")

describe Sed do


  before(:each) do
    @fake_db = double()
    @bot = TestBot.new
    @bot.database = @fake_db
    @plugin = Sed.new(@bot)
    
    @fake_db.stub(:lpush)     { true }
    @fake_db.stub(:ltrim)     { true }
    @fake_db.stub(:sismember) { false }
    @fake_db.stub(:sadd)      { true }
    
    set_test_message("PRIVMSG #coding :hi")
  end
  
  context "listening" do
    it "logs user message to user's message log in redis" do
      @plugin.should_receive(:set_last_message)
      @plugin.listen(@message)
    end
    
    it "logs user message to channel's message log in redis if a channel" do
      @plugin.should_receive(:set_last_channel_message)
      @plugin.listen(@message)
    end
    
    it "does not log message to channel if message was not from a channel" do
      set_test_message("PRIVMSG TestBot :hi")
      @plugin.should_not_receive(:set_last_channel_message)
      @plugin.listen(@message)
    end
    
    it "does not log the message if message is a sed command itself" do
      set_test_message("PRIVMSG TestBot :s/foo/bar/")
      @fake_db.should_not_receive(:set_last_message)
      @plugin.listen(@message)
    end
    
    it "logs the user of the message" do
      @plugin.should_receive(:log_user)
      @plugin.listen(@message)
    end
  end
  
  context "#set_last_message" do  
    it "should not log the message if user is already in the set" do
      @fake_db.stub(:sismember) { true }
      @fake_db.should_not_receive(:sadd)
      @plugin.listen(@message)
    end
    
    it "pushes the message onto the user's message set" do
      @fake_db.should_receive(:lpush).with("user:Test:messages", "hi")
      @plugin.listen(@message)
    end
    
    it "trims user message set to 1000 max" do
      @fake_db.should_receive(:ltrim).with("user:Test:messages", 0 , 1000)
      @plugin.listen(@message)
    end
  end
  
  context "#log_user" do
    it "logs the user's name to users_logged if not already in the list" do
      @fake_db.should_receive(:sadd).with("users_logged", "Test")
      @plugin.listen(@message)
    end
  end
end