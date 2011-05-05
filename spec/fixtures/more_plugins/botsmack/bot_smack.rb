class BotSmack
  include Cinch::Plugin
  prefix "@"
  match "botsmack"
  
  def execute(m)
    m.reply "What?! D-:"
  end
end