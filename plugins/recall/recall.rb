class Recall
  include Cinch::Plugin
  
  match /recall (\S+)(\s{1}\S+)?/
  
  def execute(m, lines, target = nil)
    if target.nil?
      target = m.user.nick
    else
      target.lstrip!
    end
    
    if lines =~ /^([0-9]+)$/
      line_start = 0
      line_count = $1.to_i - 1
      m.user.privmsg "Recalling the last #{line_count} lines logged for #{target}:"
    elsif lines =~ /^([0-9]+)-([0-9]+)$/
      line_start = $1.to_i - 1
      line_end = $2.to_i - 1
      line_count = line_start - line_end
      m.user.privmsg "Recalling lines #{line_start}-#{line_end} logged for #{target}:"
    else
      m.privmsg "Unable to interpret line counts for recall, try again."
      return
    end
    lines = @bot.database.lrange("user:#{target}:messages",line_start, line_count) 
    lines.reverse.each do |line|
      m.user.privmsg "<#{target}> #{line}"
    end
  end
end