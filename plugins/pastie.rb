require 'pastie-api'

class PastieCmd
  include Cinch::Plugin
  
  listen_to :private
  match /^@pastie start$/, method: :start, :use_prefix => false
  match /^@pastie stop$/, method: :stop, :use_prefix => false
  
  def listen(m)
    @pasties ||= []
    @listening_to ||= []
    @pastie_lines ||= {}
    
    if @listening_to.include? m.user.nick
      unless m.message == "@pastie start" || m.message == "@pastie stop"
        @pastie_lines[m.user.nick] << m.message
      end
    end
  end
  
  def start(m)
    @listening_to << m.user.nick
    @pastie_lines[m.user.nick] = []
    m.reply "Now listening until you say @pastie stop."
  end
  
  def stop(m)
    if @listening_to.include? m.user.nick
      if @pastie_lines[m.user.nick].count  == 0
        m.reply "Blank pastie, will not post."
      else
        content = @pastie_lines[m.user.nick].join("\n")
        begin
          p = Pastie.create(content)
        rescue RuntimeError => err
          bot.logger.debug err.message
          m.reply "Error creating pastie."
          return
        end 
        @pasties << p
        m.reply "Pastie URL: #{p.link}"
      end
      @pastie_lines.delete(m.user.nick)
      @listening_to.delete(m.user.nick)
    else
      m.reply "You did not start a pastie to begin with. Start a pastie with @pastie start"
    end
  end
end