require 'spec_helper'

CadBot::PluginSet.new.load_plugin(CadBot.root + "/plugins/obedience/obedience.rb")

describe Obedience do
  before(:each) do
    @fake_db = double()
    @bot = TestBot.new
    @bot.database = @fake_db
    @plugin = Obedience.new(@bot)
  end

  describe "#botsnack" do
    before(:each) do
      raw = ":Test!test@network.com PRIVMSG #coding :@botsnack"
      @fake_db.stub(:incr) { 1 }
      @message = Cinch::Message.new(raw, @bot)
    end

    it "should send back a nice response" do
      @message.should_receive(:reply).with("Thank You! :-)")
      @fake_db.should_receive(:incr)
      @plugin.feed(@message)
    end
  end


  describe "#botsmack" do
    before(:each) do
      @raw = ":Test!test@network.com PRIVMSG #coding :@botsmack"
      @fake_db.stub(:incr) { 1 }
      @message = Cinch::Message.new(@raw, @bot)
    end

    it "should send back an unhappy response" do
      @message.should_receive(:reply).with("?!? D-:")
      @plugin.discipline(@message)
    end
  end
end
