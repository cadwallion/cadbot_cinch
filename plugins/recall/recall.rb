class Recall
  include Cinch::Plugin
  
  match /recall (.+)/
  
  def execute(m, lines)
    if lines =~ /(\d+)/
      line_start = 0
      line_count = $1.to_i
      m.user.privmsg "Recalling the last #{line_count} lines logged for you:"
    elsif lines =~ /(\d+)-(\d+)/
      line_start = $1.to_i
      line_count = $2.to_i - line_start
      line_end = line_start + line_count
      m.user.privmsg "Recalling lines #{line_start}-#{line_end} logged for you:"
    else
      m.privmsg "Unable to interpret line counts for recall, try again."
      return
    end
    lines = @bot.database.lrange("user:#{m.user.nick}:messages",line_start, line_count) 
    lines.each do |line|
      m.user.privmsg "<#{m.user.nick}> #{line}"
    end
  end
end