require 'ostruct'
class Seen
  include Cinch::Plugin
  include MessageMethods
  
  listen_to :channel
  
  match /seen (.+)/

  def listen(m)
    @bot.database.set("user:#{m.user.nick}:last_spoke", Time.now)
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

