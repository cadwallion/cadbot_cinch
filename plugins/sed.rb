class Sed
  include Cinch::Plugin
  
  listen_to :channel
  SED_REGEX = /^s\/(.+?)\/(.+?)(\/\S+|\/|$)/
  match SED_REGEX, :use_prefix => false
  
  def listen(m)
    unless m.message =~ SED_REGEX
      set_last_message(m.user.nick, m.message)
    end
  end
  
  def execute(m, matcher, replacement, conditional)
    count = (conditional =~ /([0-9]+)/ ? $1.to_i : 1)
    original = get_user_message(m.user.nick, count)
    
    if original.nil?
      m.reply "You need to say something first."
      return
    end
  
    if conditional.include? 'g'
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
    CadBot::Database.connection.lrange("user:#{user}:messages", (scrollback - 1), 1)[0]
  end
end