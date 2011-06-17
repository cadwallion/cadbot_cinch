require 'cad_bot'

CadBot::Database.test = true

class TestBot < Cinch::Bot
  attr_reader :raw_log
  def initialize(*args)
    super
    @irc = TestIRC.new
    @raw_log = []
    @logger = Cinch::Logger::NullLogger.new
  end

  def raw(command)
    @raw_log << command
  end
end

class TestIRC 
  attr_reader :isupport
  def initialize
    @isupport = Cinch::ISupport.new
  end
end

def load_plugin(plugin_class)
  load CadBot.root + "/plugins/#{plugin_class}/#{plugin_class}.rb"
end

def set_test_message(raw, user = "Test!test@network.com")
  @message = Cinch::Message.new(":#{user} #{raw}", @bot)
end