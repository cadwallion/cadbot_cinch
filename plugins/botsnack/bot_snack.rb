class BotSnack
  include Cinch::Plugin
  match "botsnack", method: :feed
  match "snackcount", method: :status
  
  def feed(m)
    m.reply "Thank You! :-)"
    @bot.database.incr("botsnacks")
  end
  
  def status(m)
    m.reply "Total snacks eaten: #{@bot.database.get("botsnacks")}"
  end
end