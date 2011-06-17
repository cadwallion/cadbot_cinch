require 'spec_helper'

load_plugin("obedience")

describe Obedience do
  before(:each) do
    @fake_db = double()
    @bot = TestBot.new
    @bot.database = @fake_db
    @plugin = Obedience.new(@bot)
  end

  describe "#botsnack" do
    before(:each) do
      @fake_db.stub(:incr) { 1 }
      set_test_message(":Test!test@network.com PRIVMSG #coding :@botsnack")
    end

    it "should send back a nice response" do
      @message.should_receive(:reply).with("Thank You! :-)")
      @fake_db.should_receive(:incr)
      @plugin.feed(@message)
    end
  end


  describe "#botsmack" do
    before(:each) do
      set_test_message(":Test!test@network.com PRIVMSG #coding :@botsmack")
      @fake_db.stub(:incr) { 1 }
    end

    it "should send back an unhappy response" do
      @message.should_receive(:reply).with("?!? D-:")
      @plugin.discipline(@message)
    end
  end
end
