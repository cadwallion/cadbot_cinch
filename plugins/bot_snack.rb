class BotSnack
  include Cinch::Plugin
  
  prefix "@"
  match "botsnack"
  
  def execute(m)
    m.reply "Thank You! :-)"
  end
end