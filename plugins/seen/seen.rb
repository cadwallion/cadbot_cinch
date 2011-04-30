require 'ostruct'
class Seen
  include Cinch::Plugin
  
  listen_to :channel
  
  match /seen (.+)/

  def initialize(*args)
    super
    @users = {}
  end

  def listen(m)
    @bot.database.set("user:#{m.user.nick}:last_spoke", Time.now)
    begin
      klass = Module.const_get("Sed")
      klass.is_a?(Class)
    rescue NameError
      if !@bot.database.sismember("users_logged", m.user.nick)
        @bot.database.sadd("users_logged", m.user.nick)
      end
      @bot.database.lpush("user:#{m.user.nick}:message", m.message)
      @bot.database.ltrim("user:#{m.user.nick}:message", 1000)
      @bot.database.set("user:#{m.user.nick}:channel", m.channel)
    end
  end

  def execute(m, nick)
    if nick == @bot.nick
      m.reply "That's me!"
    elsif nick == m.user.nick
      m.reply "That's you!"
    elsif @bot.database.sismember("users_logged", m.user.nick)
      channel = @bot.database.get("user:#{m.user.nick}:channel")
      time = @bot.database.get("user:#{m.user.nick}:last_spoke").asctime
      m.reply "#{m.user.nick} was last seen in #{channel} at #{time}"
    else
      m.reply "I haven't seen #{nick}"
    end
  end
end

