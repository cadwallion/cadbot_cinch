class Sed
  include Cinch::Plugin
  
  listen_to :channel
  SED_REGEX = /^s\/(.*)\/(.*)\/?(\S+)?$/
  match SED_REGEX, :use_prefix => false
  
  def listen(m)
    unless m.message =~ SED_REGEX
      set_last_message(m.user.nick, m.message)
    end
  end
  
  def execute(m, matcher, replacement, conditionals)
    if conditionals =~ /([0-9]+)/
      original = get_message(m.user.nick, $1)
    else
      original = get_message(m.user.nick)
    end
    if original.nil?
      m.reply "You have to say something first."
      return
    end
    if conditionals.include? 'g'
      replacement = original.gsub(matcher, replacement)
    else
      replacement = original.sub(matcher, replacement)
    end
    m.reply "#{m.user.nick} meant '#{replacement}'"
  end
  
  def set_last_message(user, message)
    CadBot::Database.connection.lpush("user:#{user}:messages", message)
    CadBot::Database.connection.ltrim("user:#{user}:messages", 0, 1000)
  end
  
  def get_user_message(user, scrollback = 1)
    CadBot::Database.connection.lrange("user:#{user}:messages", 0, (scrollback - 1))
  end
end