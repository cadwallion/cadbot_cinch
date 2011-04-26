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
  
  def execute(m, matcher, replacement, conditional)
    original = get_last_message(m.user.nick)
    if original.nil?
      m.reply "You have to say something first."
      return
    end
    if conditional == 'g'
      replacement = original.gsub(matcher, replacement)
    else
      replacement = original.sub(matcher, replacement)
    end
    m.reply "#{m.user.nick} meant '#{replacement}'"
  end
  
  def set_last_message(user, message)
    CadBot::Database.connection.set("user:#{user}:last_message", message)
  end
  
  def get_last_message(user)
    CadBot::Database.connection.get("user:#{user}:last_message")
  end
end